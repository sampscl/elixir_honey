defmodule Installer.SystemBuilder.Manager do
  @moduledoc """
  Manager for building systems dynamically as the installer runs.
  """
  import ShorterMaps
  use GenServer
  use LoggerUtils

  ##############################
  # API
  ##############################

  @zone_discovery_chnl PubSub.zone_discovery_chnl()

  def start_link(:ok), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Get all zones as a MapSet. The zones can be re-discovered dynamically and so
  after update_configuration/1 is called to add the current zones to a system,
  those same zones will eventually be re-discovered.

  ## Returns
  - MapSet.t of all discovered zone ids
  """
  def get_zones, do: GenServer.call(__MODULE__, :get_zones)

  @doc """
  Update the system named `system_name` in `Config.Manager` by adding
  all the zones held here to the configuration. If the system already
  exists in the config manager, then the zones are added to it. Otherwise
  an empty system is created first.
  ## Parameters
  - `system_name` String name of the system to create / expand
  ## Returns
  - `:ok` All is well
  """
  def update_configuration(system_name), do: GenServer.call(__MODULE__, {:update_configuration, system_name})

  @doc """
  Remove a zone by id
  ## Parameters
  - id: Integer zone to remove
  ## Returns
  - :ok
  """
  def remove_zone(id), do: GenServer.call(__MODULE__, {:remove_zone, id})

  defmodule State do
    @moduledoc false
    defstruct [
      zones: MapSet.new(), # k: zone_index
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  @impl GenServer
  def init(:ok) do
    LoggerUtils.info("Starting")
    PubSub.sub_zone_discovery()
    {:ok, ~M{%State}}
  end

  @impl GenServer
  def handle_call(:get_zones, _from, ~M{zones} = state) do
    {:reply, zones, state}
  end

  @impl GenServer
  def handle_call({:remove_zone, id}, _from, state) do
    {updated_state, result} = do_remove_zone(state, id)
    {:reply, result, updated_state}
  end

  @impl GenServer
  def handle_call({:update_configuration, system_name}, _from, state) do
    {updated_state, result} = do_update_configuration(state, system_name)
    {:reply, result, updated_state}
  end

  @impl GenServer
  def handle_info(~M{channel: @zone_discovery_chnl, data, _node}, state) do
    {:noreply, do_zone_discovery(state, data)}
  end

  ##############################
  # Internal Calls
  ##############################

  def do_zone_discovery(~M{zones} = state, ~M{%PubSub.ZoneDiscovery id}) do
    ~M{state| zones: MapSet.put(zones, id)}
  end

  def do_remove_zone(~M{zones} = state, id) do
    {~M{state| zones: MapSet.delete(zones, id)}, :ok}
  end

  def do_update_configuration(state, system_name) do
    # TODO: implement do_update_configuration/2
    LoggerUtils.info("Updating configuration for #{system_name}")
    {state, :ok}
  end
end
