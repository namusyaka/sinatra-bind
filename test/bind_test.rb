$:.unshift(File.dirname(__FILE__))
require 'helper'

describe Sinatra::Bind do
  describe "basic usage" do
    it "can define a route" do
      mock_app do
        def hello; "Hello World" end
        on "/", to: :hello
      end
      get '/'
      assert_equal 'Hello World', last_response.body
    end

    it "can define a route correctly even if path contains named params" do
      mock_app do
        def show(id, type); "id: #{id}, type: #{type}" end
        on "/show/:id/:type", to: :show
      end
      get '/show/1234/frank'
      assert_equal 'id: 1234, type: frank', last_response.body
    end

    it "should support instance variable sharing" do
      mock_app do
        before("/foo"){ @a = "hey" }
        def hey; @a end
        on "/foo", to: :hey
      end
      get '/foo'
      assert_equal 'hey', last_response.body
    end

    it "can define a filter" do
      mock_app do
        def bar; @b = "bar" end
        def show_bar; @b end
        on "/bar", to: :bar, type: :before
        on "/bar", to: :show_bar
      end
      get '/bar'
      assert_equal 'bar', last_response.body
    end
  end

  describe "compatbility with sinatra" do
    it "can use route options" do
      mock_app do
        require 'json'
        def hello; JSON.dump(:a => "b") end
        on "/", to: :hello, provides: :json
      end
      get "/"
      assert_equal "application/json", last_response.headers["Content-Type"]
      assert_equal '{"a":"b"}', last_response.body
    end

    it "should add the HEAD route if the GET route is added" do
      mock_app do
        def hello; "hello world" end
        on "/", to: :hello
      end
      head "/"
      assert_equal 200, last_response.status
    end

    it "should invoke the :route_added hook when route is added" do
      module RouteAddedTest
        @routes, @procs = [], []
        def self.routes ; @routes ; end
        def self.procs ; @procs ; end
        def self.route_added(verb, path, proc)
          @routes << [verb, path]
          @procs << proc
        end
      end
      app = mock_app do
        register RouteAddedTest
        def hello; "hello world" end
        on "/", to: :hello
      end
      assert_equal RouteAddedTest.routes, [["GET", "/"], ["HEAD", "/"]]
      assert_equal RouteAddedTest.procs,  [app.send(:instance_method, :hello)] * 2
    end
  end
end
