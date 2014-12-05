# Sinatra::Bind

Binds instance method to routes.

## Installation

Add this line to your application's Gemfile:

    gem 'sinatra-bind'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-bind

## Usage

You can define a route without block smoothly.

```ruby
class App < Sinatra::Base
  register Sinatra::Bind

  def index
    "hello world"
  end

  on "/", to: :index
end
```

If specified the :type option, it will be used as request method.

```ruby
class App < Sinatra::Base
  register Sinatra::Bind

  def index
    "hello world"
  end

  on "/", to: :index, type: :post
end
```

If passed `:before` or `:after` inn the `:type` option, it will be added as the filters.

```ruby
class App < Sinatra::Base
  register Sinatra::Bind

  def before_index
    @foo = "bob"
  end

  def index
    "hello #{@foo}"
  end

  on "/", to: :before_index, type: :before
  on "/", to: :index
end
```

## Contributing

1. Fork it ( https://github.com/namusyaka/sinatra-bind/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
