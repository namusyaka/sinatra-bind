require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'
require 'sinatra/base'
require 'sinatra/bind'

class Sinatra::Base
  include MiniTest::Assertions
  register Sinatra::Bind
end

class MiniTest::Spec
  include Rack::Test::Methods

  class << self
    alias context describe
  end

  def app
    Rack::Lint.new(@app)
  end

  def mock_app(base = Sinatra::Base, &block)
    @app = Sinatra.new(base, &block)
    @app.set :logging, false
  end
end

