defmodule Web.Types do
  @moduledoc """
  Types supporting GraphQl
  """

  use Absinthe.Schema.Notation

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

end
