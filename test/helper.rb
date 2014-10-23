require 'bundler/setup'

require 'oktobertest'
require 'oktobertest/contrib'

require 'cuba'
require 'cuba/render'
require 'tilt'
require 'crest'

class Article
  attr_accessor :id, :title, :body

  def initialize(attrs = {})
    set_all attrs
  end

  def self.[](id)
    new id: id, title: 'Article 1'
  end

  def self.all
    [new(title: 'Article 1'), new(title: 'Article 2')]
  end

  def delete
  end

  def id
    @id || 1
  end

  def save
  end

  def set_all(attrs = {})
    attrs.each do |k, v|
      send :"#{k}=", v
    end
  end

  def valid?
    !(title.nil? || body.nil?)
  end
end

Cuba.plugin Cuba::Render
Cuba.plugin Crest

Cuba.settings[:render][:views] = File.expand_path '../views', __FILE__

Cuba.define do
  rest Article do
    on get, 'hello' do
      res.write 'hello'
    end

    on get, ':id/hello' do |id|
      res.write "hello #{id}"
    end
  end
end
