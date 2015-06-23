require 'inflecto'

module Crest
  def rest(klass, options = {}, &block)
    self.class.send :define_method, :"find_#{object_name klass}" do |id|
      klass[id]
    end unless respond_to? :"find_#{object_name klass}"

    self.class.send :define_method, :"find_#{collection_name klass}" do
      klass.all
    end unless respond_to? :"find_#{collection_name klass}"

    self.class.send :define_method, :"list_#{collection_name klass}" do
      render "#{collection_name klass}/list", :"#{collection_name klass}" => send(:"find_#{collection_name klass}")
    end unless respond_to? :"list_#{collection_name klass}"

    self.class.send :define_method, :"create_#{object_name klass}" do |object_params|
      object = klass.new object_params
      if object.valid?
        object.save
        res.redirect "#{options[:base_uri]}/#{collection_name klass}/#{object.id}"
      else
        render "#{collection_name klass}/new", :"#{object_name klass}" => object
      end
    end unless respond_to? :"create_#{object_name klass}"

    self.class.send :define_method, :"new_#{object_name klass}" do
      render "#{collection_name klass}/new", :"#{object_name klass}" => klass.new
    end unless respond_to? :"new_#{object_name klass}"

    self.class.send :define_method, :"show_#{object_name klass}" do |object|
      render "#{collection_name klass}/show", :"#{object_name klass}" => object
    end unless respond_to? :"show_#{object_name klass}"

    self.class.send :define_method, :"update_#{object_name klass}" do |object, object_params|
      object.set_all object_params
      if object.valid?
        object.save
        res.redirect "#{options[:base_uri]}/#{collection_name klass}/#{object.id}"
      else
        render "#{collection_name klass}/edit", :"#{object_name klass}" => object
      end
    end unless respond_to? :"update_#{object_name klass}"

    self.class.send :define_method, :"delete_#{object_name klass}" do |object|
      object.delete
      res.redirect "#{options[:base_uri]}/#{collection_name klass}"
    end unless respond_to? :"delete_#{object_name klass}"

    self.class.send :define_method, :"edit_#{object_name klass}" do |object|
      render "#{collection_name klass}/edit", :"#{object_name klass}" => object
    end unless respond_to? :"edit_#{object_name klass}"

    block.call unless block.nil?

    on root do
      on get do
        send :"list_#{collection_name klass}"
      end

      on post, param(:"#{object_name klass}") do |object_params|
        send :"create_#{object_name klass}", object_params
      end
    end

    on get, 'new' do
      send :"new_#{object_name klass}"
    end

    on :id do |id|
      object = send :"find_#{object_name klass}", id

      on root do
        on get do
          send :"show_#{object_name klass}", object
        end

        on put, param(:"#{object_name klass}") do |object_params|
          send :"update_#{object_name klass}", object, object_params
        end

        on delete do
          send :"delete_#{object_name klass}", object
        end
      end

      on 'edit' do
        send :"edit_#{object_name klass}", object
      end
    end
  end

  private

  def collection_name(klass)
    Inflecto.underscore Inflecto.pluralize(klass)
  end

  def object_name(klass)
    Inflecto.underscore klass
  end
end
