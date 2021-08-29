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
  - args: Map, keyed with the query's argument names
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

  @spec discovered_zones(map(), %Absinthe.Resolution{}) :: {:ok, list(String.t)}
  @doc """
  Resolver for discovered zones (discovered because installer mode is true)
  ## Parameters
  - _args: Map, keyed with the query's argument names (not used)
  - _resolution: %Absinthe.Resolution{} containing context and stuff

  ## Returns
  - {:ok, [zone_id]} All is well, a list of zone ids is returned
  - {:error, reason} Failed for reason
  """
  def discovered_zones(_args, _resolution) do
    if Installer.Sup.installer_mode?() do
      # Installer mode, check system builder for zones
      {:ok, Installer.SystemBuilder.Manager.get_zones() |> then(fn({:ok, zone_map_set}) -> zone_map_set end)}
    else
      # Not installer mode, no discovered zones
      {:ok, []}
    end
  end

  @doc """
  Resolver for sensors
  ## Parameters
  - system map() The system to get sensors for, returned from `systems/2`
  ## Returns
  - {:ok, [sensor]} All is well, a list of sensors is returned, see config.yml for shape
  - {:error, reason} Failed for reason
  """
  def sensors(system, _args, _resolution) do
    sensors =
      system # already atom keyed since systems/2 does that for us
      |> Map.get(:sensors)
      |> Enum.map(&(Utils.Map.atom_keys(&1)))

    {:ok, sensors}
  end

  @doc """
  Resolver for zones
  ## Parameters
  - sensor map() The sensor to get zones for, returned from `sensors/3`
  ## Returns
  - {:ok, [zone]} All is well, a list of zones is returned, see config.yml for shape
  - {:error, reason} Failed for reason
  """
  def zones(sensor, _args, _resolution) do
    zones =
      sensor
      |> Map.get(:zones)
      |> Enum.map(&(Utils.Map.atom_keys(&1)))

    {:ok, zones}
  end

  @doc """
  Resolver for installer mode
  ## Returns
  - {:ok, boolean} All is well, a boolean value is returned indicating whether the
  app is in installer mode or not
  """
  def installer_mode?(_args, _resolution) do
    {:ok, Installer.Sup.installer_mode?()}
  end
end
