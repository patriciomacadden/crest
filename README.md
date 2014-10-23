# Crest

Cuba + REST.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crest'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install crest
```

## Usage

Let's see an example:

```ruby
require 'cuba'
require 'cuba/render'
require 'crest'
require 'tilt'

Cuba.plugin Cuba::Render
Cuba.plugin Crest

Cuba.define do
  rest Article # asuming that you have an Article model.
end
```

That'll give you these routes:

* `GET /articles`: will render the `list` template (not provided), passing the
`articles` variable.
* `POST /articles`: will render the `new` template (not provided) if `article`
is not valid (calling `article.valid?`) or it'll create a new `Article` and
redirect to `/articles/:id` if valid.
* `GET /articles/new`: will render the `new` template (not provided), passing
the `article` variable: a newly created `Article`.
* `GET /articles/:id`: will render the `show` template (not provided), passing
the `article` variable: an object retrieved by calling `Article[id]`.
* `GET /articles/:id/edit`: will render the `edit` template (not provided),
passing the `article` variable: an object retrieved by calling `Article[id]`.
* `DELETE /articles/:id`: will delete the object and redirect to `/articles`.
* `PUT /articles/:id`: will render the `edit` template (not provided) if
`article` is not valid (calling `article.valid?`) or it'll update the a new
`Article` and redirect to `/articles/:id` if valid.

### What if I want to add more routes to a rest routeset?

Well, just send a block along with the class name, like this:

```ruby
Cuba.define do
  rest Article do
    on get, 'something' do
      res.write 'hello'
    end
  end
end
```

And that'll give you also this route: `GET /articles/something`.

Quite easy!

### What if I want to overwrite a route?

Well, every route has its own method. For instance, `/articles` calls the
`list_articles` method, which is defined when you call the `rest` method. If
you want to overwrite the basic behavior (eg. paginate results), you can
overwrite the `list_articles` method:

```ruby
class App < Cuba
  def list_articles
    render 'list', articles: Article.published
  end

  define do
    rest Article
  end
end
```

Quite simple!

Defined methods are:

* `list_`
* `create_`
* `new_`
* `show_`
* `update_`
* `delete_`
* `edit_`

## Assumptions

There are a few assumptions made by crest:

* Your *model* must respond to `all` in order to retrieve a collection
* Your *model* must respond to `[]` in order to retrieve one object
* Your *model* must respond to `valid?`
* Your *model* must respond to `save`
* Your *model* must respond to `set_all`
* Your *model* must respond to `all`

That said, if you use [Sequel](http://sequel.jeremyevans.net), you're all set.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

See the [LICENSE](https://github.com/patriciomacadden/crest/blob/master/LICENSE).
