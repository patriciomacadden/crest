require 'inflecto'

module Crest
  def rest(klass, options = {}, &block)
    self.class.send :define_method, :"list_#{Inflecto.underscore Inflecto.pluralize(klass)}" do
      render "#{Inflecto.underscore Inflecto.pluralize(klass)}/list", :"#{Inflecto.underscore Inflecto.pluralize(klass)}" => klass.all
    end unless respond_to? :"list_#{Inflecto.underscore Inflecto.pluralize(klass)}"

    self.class.send :define_method, :"create_#{Inflecto.underscore klass}" do |object_params|
      object = klass.new object_params
      if object.valid?
        object.save
        res.redirect "#{options[:base_uri]}/#{Inflecto.underscore Inflecto.pluralize(klass)}/#{object.id}"
      else
        render "#{Inflecto.underscore Inflecto.pluralize(klass)}/new", :"#{Inflecto.underscore klass}" => object
      end
    end unless respond_to? :"create_#{Inflecto.underscore klass}"

    self.class.send :define_method, :"new_#{Inflecto.underscore klass}" do
      render "#{Inflecto.underscore Inflecto.pluralize(klass)}/new", :"#{Inflecto.underscore klass}" => klass.new
    end unless respond_to? :"new_#{Inflecto.underscore klass}"

    self.class.send :define_method, :"show_#{Inflecto.underscore klass}" do |object|
      render "#{Inflecto.underscore Inflecto.pluralize(klass)}/show", :"#{Inflecto.underscore klass}" => object
    end unless respond_to? :"show_#{Inflecto.underscore klass}"

    self.class.send :define_method, :"update_#{Inflecto.underscore klass}" do |object, object_params|
      object.set_all object_params
      if object.valid?
        object.save
        res.redirect "#{options[:base_uri]}/#{Inflecto.underscore Inflecto.pluralize(klass)}/#{object.id}"
      else
        render "#{Inflecto.underscore Inflecto.pluralize(klass)}/edit", :"#{Inflecto.underscore klass}" => object
      end
    end unless respond_to? :"update_#{Inflecto.underscore klass}"

    self.class.send :define_method, :"delete_#{Inflecto.underscore klass}" do |object|
      object.delete
      res.redirect "#{options[:base_uri]}/#{Inflecto.underscore Inflecto.pluralize(klass)}"
    end unless respond_to? :"delete_#{Inflecto.underscore klass}"

    self.class.send :define_method, :"edit_#{Inflecto.underscore klass}" do |object|
      render "#{Inflecto.underscore Inflecto.pluralize(klass)}/edit", :"#{Inflecto.underscore klass}" => object
    end unless respond_to? :"edit_#{Inflecto.underscore klass}"

    block.call unless block.nil?

    on root do
      on get do
        send :"list_#{Inflecto.underscore Inflecto.pluralize(klass)}"
      end

      on post, param(:"#{Inflecto.underscore klass}") do |object_params|
        send :"create_#{Inflecto.underscore klass}", object_params
      end
    end

    on get, 'new' do
      send :"new_#{Inflecto.underscore klass}"
    end

    on :id do |id|
      object = klass[id]

      on root do
        on get do
          send :"show_#{Inflecto.underscore klass}", object
        end

        on put, param(:"#{Inflecto.underscore klass}") do |object_params|
          send :"update_#{Inflecto.underscore klass}", object, object_params
        end

        on delete do
          send :"delete_#{Inflecto.underscore klass}", object
        end
      end

      on 'edit' do
        send :"edit_#{Inflecto.underscore klass}", object
      end
    end
  end
end
