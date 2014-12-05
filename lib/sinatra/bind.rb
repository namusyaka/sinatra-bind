require "sinatra/bind/version"

module Sinatra
  module Bind
    # Sinatra::Bind enables to define a route by using instance method.
    # In other words, you can define a route without block.
    #
    # @example
    #   module AwesomeMethods
    #     def before_article
    #       @ex = params['id'] * "!"
    #     end
    #
    #     def find_article(id)
    #       "Article##{id} #{@ex}"
    #     end
    #   end
    #
    #   class App < Sinatra::Base
    #     include AwesomeMethods
    #
    #     def index
    #       "hello world"
    #     end
    #
    #     on "/", to: :index
    #
    #     on "/articles/:id", to: :before_article, type: :before
    #     on "/articles/:id", to: :find_article
    #   end
    def self.registered(app)
      app.extend ClassMethods
    end

    module ClassMethods
      FILTER_NAMES = ['BEFORE', 'AFTER'].freeze

      # Defines a route without block smoothly
      # @param  [String] path
      # @option [String, Symbol] :to The method name that must be defined as instance method.
      # @option [String, Symbol] :type The verb means REQUEST_METHOD, also can be received as filter names.
      def on(path, options = {})
        verb = (options.delete(:type) || 'GET').to_s.upcase
        return bound_filter(verb, path, options) if FILTER_NAMES.include?(verb)
        method_name = options.delete(:to)
        process_bound_route(verb, path, method_name) do
          method = instance_method(method_name)
          bound_route(verb, path, options.merge(method_name: "#{verb} #{method_name}"), method)
        end
      end

      def bound_route(verb, path, options, method)
        host_name(options.delete(:host)) if options.key?(:host)
        signature = compile_bound_route!(verb, path, method, options)
        (@routes[verb] ||= []) << signature
        invoke_hook(:route_added, verb, path, method)
        signature
      end

      def bound_filter(type, path, options)
        path, options = //, path if path.respond_to?(:each_pair)
        method = instance_method(options.delete(:to))
        filters[type.downcase.to_sym] << compile_bound_route!(type, path || //, method, options)
      end

      def compile_bound_route!(verb, path, unbound_method, options)
        method_name = options.delete(:method_name)
        options.each_pair { |option, args| send(option, *args) }
        pattern, keys = compile path
        conditions, @conditions = @conditions, []
        wrapper = unbound_method.arity != 0 ?
          proc { |a,p| unbound_method.bind(a).call(*p) } :
          proc { |a,p| unbound_method.bind(a).call }
        wrapper.instance_variable_set(:@route_name, method_name)
        [ pattern, keys, conditions, wrapper ]
      end

      def process_bound_route(verb, path, method_name)
        return yield unless verb == 'GET'
        conditions = @conditions.dup; yield; @conditions = conditions
        on path, to: method_name, type: 'HEAD'
      end

      private :bound_route, :bound_filter, :compile_bound_route!, :process_bound_route
    end
  end
end
