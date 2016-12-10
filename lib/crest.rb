require "inflecto"

module Crest
  def base_uri; nil; end

  def collection_name
    Inflecto.underscore self.class.name
  end

  def object_name
    Inflecto.underscore Inflecto.singularize(self.class.name)
  end

  def index
    render "#{collection_name}/index", "#{collection_name}": send(:"find_#{collection_name}")
  end

  def new
    render "#{collection_name}/new", "#{object_name}": send(:"initialize_#{object_name}")
  end

  def create(object_param)
    object = send :"initialize_#{object_name}", object_param
    if object.valid?
      object.save
      res.redirect "#{base_uri}/#{collection_name}/#{object.id}"
    else
      render "#{collection_name}/new", "#{object_name}": object
    end
  end

  def edit(object)
    render "#{collection_name}/edit", "#{object_name}": object
  end

  def update(object, object_param)
    object.set_all object_param
    if object.valid?
      object.save
      res.redirect "#{base_uri}/#{collection_name}/#{object.id}"
    else
      render "#{collection_name}/edit", "#{object_name}": object
    end
  end

  def show(object)
    render "#{collection_name}/show", "#{object_name}": object
  end

  def destroy(object)
    object.delete
    res.redirect "#{base_uri}/#{collection_name}"
  end

  def define_routes(&block)
    block.call unless block.nil?

    on root do
      on get do
        index
      end

      on post, param(:"#{object_name}") do |object_param|
        create object_param
      end
    end

    on get, "new" do
      new
    end

    on :id do |id|
      object = send :"find_#{object_name}", id

      on root do
        on get do
          show object
        end

        on put, param(:"#{object_name}") do |object_param|
          update object, object_param
        end

        on delete do
          destroy object
        end
      end

      on "edit" do
        edit object
      end
    end
  end
end

