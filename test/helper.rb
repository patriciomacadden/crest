require 'bundler/setup'

require 'oktobertest'
require 'oktobertest/contrib'

require 'cuba'
require 'cuba/render'
require 'tilt'
require 'crest'

class FakeModel
  def initialize(attrs = {})
    set_all attrs
  end

  def delete
  end

  def save
  end

  def set_all(attrs = {})
    attrs.each do |k, v|
      send :"#{k}=", v
    end
  end
end

class Article < FakeModel
  attr_accessor :id, :title, :body

  # This method is inconsistent with #valid?
  # As this is a Fake Model, we need to return an object that's not valid for
  # some tests
  def self.[](id)
    new id: id, title: 'Article 1'
  end

  def self.all
    [new(title: 'Article 1', body: 'Lorem ipsum'), new(title: 'Article 2', body: 'Lorem ipsum')]
  end

  def id
    @id || 1
  end

  def valid?
    !(title.nil? || body.nil?)
  end
end

class Comment < FakeModel
  attr_accessor :id, :name, :body

  # This method is inconsistent with #valid?
  # As this is a Fake Model, we need to return an object that's not valid for
  # some tests
  def self.[](id)
    new id: id, name: 'Patricio'
  end

  def self.all
    [new(name: 'Patricio', body: 'Lorem ipsum'), new(name: 'Matz', body: 'Lorem ipsum')]
  end

  def id
    @id || 1
  end

  def valid?
    !(name.nil? || body.nil?)
  end
end

Cuba.plugin Cuba::Render
Cuba.plugin Crest

Cuba.settings[:render][:views] = File.expand_path '../views', __FILE__

Cuba.define do
  on 'articles' do
    rest Article do
      on get, 'hello' do
        res.write 'hello'
      end

      on get, ':id/hello' do |id|
        res.write "hello #{id}"
      end
    end
  end
end
