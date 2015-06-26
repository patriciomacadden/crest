require 'inflecto'

module Crest
  def rest(klass, options = {}, &block)
    collection_name = Inflecto.underscore Inflecto.pluralize(klass)
    object_name = Inflecto.underscore klass

    define_handler "find_#{object_name}" do |id|
      klass[id]
    end

    define_handler "find_#{collection_name}" do
      klass.all
    end

    define_handler "list_#{collection_name}" do
      render "#{collection_name}/list", :"#{collection_name}" => send(:"find_#{collection_name}")
    end

    define_handler "create_#{object_name}" do |object_params|
      object = klass.new object_params
      if object.valid?
        object.save
        res.redirect "#{options[:base_uri]}/#{collection_name}/#{object.id}"
      else
        render "#{collection_name}/new", :"#{object_name}" => object
      end
    end

    define_handler "new_#{object_name}" do
      render "#{collection_name}/new", :"#{object_name}" => klass.new
    end

    define_handler "show_#{object_name}" do |object|
      render "#{collection_name}/show", :"#{object_name}" => object
    end

    define_handler "update_#{object_name}" do |object, object_params|
      object.set_all object_params
      if object.valid?
        object.save
        res.redirect "#{options[:base_uri]}/#{collection_name}/#{object.id}"
      else
        render "#{collection_name}/edit", :"#{object_name}" => object
      end
    end

    define_handler "delete_#{object_name}" do |object|
      object.delete
      res.redirect "#{options[:base_uri]}/#{collection_name}"
    end

    define_handler "edit_#{object_name}" do |object|
      render "#{collection_name}/edit", :"#{object_name}" => object
    end

    block.call unless block.nil?

    on root do
      on get do
        send :"list_#{collection_name}"
      end

      on post, param(:"#{object_name}") do |object_params|
        send :"create_#{object_name}", object_params
      end
    end

    on get, 'new' do
      send :"new_#{object_name}"
    end

    on :id do |id|
      object = send :"find_#{object_name}", id

      on root do
        on get do
          send :"show_#{object_name}", object
        end

        on put, param(:"#{object_name}") do |object_params|
          send :"update_#{object_name}", object, object_params
        end

        on delete do
          send :"delete_#{object_name}", object
        end
      end

      on 'edit' do
        send :"edit_#{object_name}", object
      end
    end
  end

  private

  def define_handler(name, &body)
    self.class.send(:define_method, name, &body)  unless respond_to? name
  end
end
