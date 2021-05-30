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
  Get all zones as a MapSet

  ## Returns
  - MapSet.t of all discovered zone ids
  """
  def get_zones, do: GenServer.call(__MODULE__, :get_zones)

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
end
