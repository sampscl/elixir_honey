defmodule Web.Resolver do
  @moduledoc """
  Resolver functions for GraphQL
  """

  import ShorterMaps
  use LoggerUtils

  @spec systems(map(), %Absinthe.Resolution{}) :: {:ok, list(map())}
  @doc """
  Resolver for systems
  ## Parameters
  - _args: Map, keyed with the query's argument names
  - resolution: %Absinthe.Resolution{} containing context and stuff

  ## Returns
  - {:ok, [system]} All is well, a list of systems is returned; see config.yml for shape
  - {:error, reason} Failed for reason
  """
  def systems(args, resolution)
  def systems(~M{name: nil} = _args, _resolution) do
    {:ok, systems} = Config.Manager.get_systems()
    result = Enum.map(systems, &(Utils.Map.atom_keys(&1)))
    {:ok, result}
  end
  def systems(~M{name} = _args, _resolution) do
    case Config.Manager.get_systems() do
      {:ok, systems} ->
        result =
          systems
          |> Enum.filter(&(name == &1["name"]))
          |> Enum.map(&{Utils.Map.atom_keys(&1)})
        {:ok, result}
      err -> err
    end
  end
  def systems(_args, resolution), do: systems(%{name: nil}, resolution)

  def sensors(system, _args, _resolution) do
    sensors =
      system # already atom keyed since systems/2 does that for us
      |> Map.get(:sensors)
      |> Enum.map(&(Utils.Map.atom_keys(&1)))

    {:ok, sensors}
  end

  def zones(sensor, _args, _resolution) do
    zones =
      sensor
      |> Map.get(:zones)
      |> Enum.map(&(Utils.Map.atom_keys(&1)))

    {:ok, zones}
  end

  def installer_mode?(_args, _resolution) do
    {:ok, Installer.Sup.installer_mode?()}
  end
end
