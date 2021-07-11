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

  import_types Web.Types

  query do
    field :item, :item do
      arg :id, non_null(:id)
      resolve fn %{id: item_id}, _ ->
        {:ok, @items[item_id]}
      end
    end

    @desc "Check if in installer mode"
    field :is_installer_mode, :boolean do
      resolve &Web.Resolver.installer_mode?/2
    end

    @desc "Get all configured systems"
    field :systems, list_of(:system) do
      arg :name, :string
      resolve &Web.Resolver.systems/2
    end

    @desc "Get discovered zones"
    field :zones, list_of(:zone) do
      resolve &Web.Resolver.discovered_zones/2
    end
  end
end
