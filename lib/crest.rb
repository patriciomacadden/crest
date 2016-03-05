require 'inflecto'

module Crest
  module PathHelper
    module ClassMethods
      def define_paths_for(klass)
        collection_name = Inflecto.underscore Inflecto.pluralize(klass)
        object_name = Inflecto.underscore klass

        unless instance_methods.include? :"#{object_name}_path"
          define_method :"#{object_name}_path" do |object|
            "#{base_uri}/#{collection_name}/#{object.id}"
          end
        end

        unless instance_methods.include? :"#{collection_name}_path"
          define_method :"#{collection_name}_path" do
            "#{base_uri}/#{collection_name}"
          end
        end

        unless instance_methods.include? :"edit_#{object_name}_path"
          define_method :"edit_#{object_name}_path" do |object|
            "#{base_uri}/#{collection_name}/#{object.id}/edit"
          end
        end

        unless instance_methods.include? :"new_#{object_name}_path"
          define_method :"new_#{object_name}_path" do
            "#{base_uri}/#{collection_name}/new"
          end
        end
      end
    end
  end

  def base_uri
    nil
  end

  def rest(klass, &block)
    collection_name = Inflecto.underscore Inflecto.pluralize(klass)
    object_name = Inflecto.underscore klass

    define_handler("before_create_#{object_name}") { true }
    define_handler("before_delete_#{object_name}") { |object| true }
    define_handler("before_edit_#{object_name}") { |object| true }
    define_handler("before_list_#{collection_name}") { true }
    define_handler("before_new_#{object_name}") { true }
    define_handler("before_show_#{object_name}") { |object| true }
    define_handler("before_update_#{object_name}") { |object| true }

    define_handler "create_#{object_name}" do |object_param|
      send :"before_create_#{object_name}"
      object = send :"initialize_#{object_name}", object_param
      if object.valid?
        object.save
        res.redirect "#{base_uri}/#{collection_name}/#{object.id}"
      else
        render "#{collection_name}/new", :"#{object_name}" => object
      end
    end

    define_handler "delete_#{object_name}" do |object|
      send :"before_delete_#{object_name}", object
      object.delete
      res.redirect "#{base_uri}/#{collection_name}"
    end

    define_handler "edit_#{object_name}" do |object|
      send :"before_edit_#{object_name}", object
      render "#{collection_name}/edit", :"#{object_name}" => object
    end

    define_handler "find_#{object_name}" do |id|
      klass[id]
    end

    define_handler "find_#{collection_name}" do
      klass.all
    end

    define_handler "initialize_#{object_name}" do |object_param|
      klass.new object_param
    end

    define_handler "list_#{collection_name}" do
      send :"before_list_#{collection_name}"
      render "#{collection_name}/list", :"#{collection_name}" => send(:"find_#{collection_name}")
    end

    define_handler "new_#{object_name}" do
      send :"before_new_#{object_name}"
      render "#{collection_name}/new", :"#{object_name}" => klass.new
    end

    define_handler "show_#{object_name}" do |object|
      send :"before_show_#{object_name}", object
      render "#{collection_name}/show", :"#{object_name}" => object
    end

    define_handler "update_#{object_name}" do |object, object_param|
      send :"before_update_#{object_name}", object
      object.set_all object_param
      if object.valid?
        object.save
        res.redirect "#{base_uri}/#{collection_name}/#{object.id}"
      else
        render "#{collection_name}/edit", :"#{object_name}" => object
      end
    end

    block.call unless block.nil?

    on root do
      on get do
        send :"list_#{collection_name}"
      end

      on post, param(:"#{object_name}") do |object_param|
        send :"create_#{object_name}", object_param
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

        on put, param(:"#{object_name}") do |object_param|
          send :"update_#{object_name}", object, object_param
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
    self.class.send(:define_method, name, &body) unless respond_to? name
  end
end
