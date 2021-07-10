defmodule Web.Schema do
  @moduledoc """
  The GraphQL schema
  """
  use Absinthe.Schema

  # Example data
  @items %{
    "foo" => %{id: "foo", name: "Foo"},
    "bar" => %{id: "bar", name: "Bar"}
  }

  @desc "An item"
  object :item do
    field :id, :id
    field :name, :string
  end

  @desc "A radio"
  object :radio do
    field :name, :string
    field :type, :string
    field :index, :integer
  end

  @desc "A zone"
  object :zone do
    field :id, :integer
    field :name, :string
    field :type, :string
    field :perimeter, :boolean
  end

  @desc "A sensor"
  object :sensor do
    field :type, :string
    field :source, :radio
    field :zones, list_of(:zone) do
      resolve &Web.Resolver.zones/3
    end
  end

  @desc "A system"
  object :system do
    field :name, :string
    field :sensors, list_of(:sensor) do
      arg :type, :string
      resolve &Web.Resolver.sensors/3
    end
  end

  query do
    field :item, :item do
      arg :id, non_null(:id)
      resolve fn %{id: item_id}, _ ->
        {:ok, @items[item_id]}
      end
    end

    field :systems, list_of(:system) do
      arg :name, :string
      resolve &Web.Resolver.systems/2
    end

    field :is_installer_mode, :boolean do
      resolve &Web.Resolver.installer_mode?/2
    end

  end

end
