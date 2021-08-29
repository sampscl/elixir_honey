defmodule Config.Manager do
  @moduledoc """
  Genserver for managing the system configuration. Must be started first!
  """
  use GenServer
  use QolUp.LoggerUtils
  import ShorterMaps

  ##############################
  # API
  ##############################

  @known_radio_types ~w(rtl-sdr)
  # @known_sensor_types ~w(honeywell_345)

  def start_link(:ok), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Get a name-keyed map of configured systems
  ## Returns
  - {:ok, %{}} All is well, k: string name, v: %System.t
  - {:error, reason} Failed for reason
  """
  def get_systems, do: GenServer.call(__MODULE__, :get_systems)

  @doc """
  Define a radio in the configuration; {type, index} form a unique pair
  ## Params
  - name: String The radio name, can be nil if unknown
  - type: String The radio type
  - index: Integer The index of this radio if multiples of the same type are possible
  ## Return
  - :ok All is well, the radio was defined or updated
  - {:error, reason} Failed for some reason
  """
  def define_radio(name, type, index),
    do: GenServer.call(__MODULE__, {:define_radio, name, type, index})

  @doc """
  Get a list of all radios
  ## Returns
  - {:ok, [Radio.t]} All is well
  - {:error, reason} Failed for some reason
  """
  def get_radios, do: GenServer.call(__MODULE__, :get_radios)

  defmodule Radio do
    @moduledoc "How a radio is defined"
    defstruct [
      # pretty name for the radio
      name: nil,
      # type, must be in @known_radio_types
      type: nil,
      # radio index to differentiata multiples of same type
      index: nil
    ]

    @type t :: %__MODULE__{}
  end

  defmodule Zone do
    @moduledoc "How a zone is defined"
    defstruct [
      # zone id
      id: 0,
      # human friendly name
      name: "",
      # the type of this zone ~w(reed)
      type: "",
      # whether zone is on the secure perimeter
      perimeter: false
    ]

    @type t :: %__MODULE__{}
  end

  defmodule Sensor do
    @moduledoc "How a sensor is defined"
    defstruct [
      # sensor type
      type: "",
      # the radio that will receive reports from this sensor
      source: %Radio{},
      # %Zone{}
      zones: []
    ]

    @type t :: %__MODULE__{}
  end

  defmodule System do
    @moduledoc "How a system is defined"
    defstruct [
      # THe system name; unique
      name: "",
      # sensors in the system; each sensor belongs to 1 system
      sensors: []
    ]

    @type t :: %__MODULE__{}
  end

  defmodule State do
    @moduledoc false
    defstruct [
      # k: system name string, v: Systen.t
      systems: %{},
      # k: {type, index}, v: %Radio{}
      radios: %{}
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  @impl GenServer
  def init(:ok) do
    QolUp.LoggerUtils.info("Starting")

    state = update_state_from_cfg(%State{}, read_example_config())

    QolUp.LoggerUtils.debug(inspect(~M{state}, pretty: true))

    # publish all the stuff from config
    state
    |> Map.get(:systems)
    |> Enum.reduce([], fn {_name, system}, radio_list ->
      PubSub.pub_system_configured(~M{%PubSub.SystemConfigured system})

      Enum.reduce(system.sensors, nil, fn sensor, _ ->
        Enum.each(sensor.zones, fn zone ->
          PubSub.pub_zone_discovery(~M{%PubSub.ZoneDiscovery zone})
        end)

        [sensor.source | radio_list]
      end)
    end)
    |> Enum.uniq()
    |> Enum.each(fn radio ->
      PubSub.pub_radio_discovery(~M{%PubSub.RadioDiscovery radio})
    end)

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_systems, _from, state) do
    {:reply, {:ok, state.systems}, state}
  end

  @impl GenServer
  def handle_call({:define_radio, name, type, index}, _from, state) do
    {new_state, response} = do_define_radio(state, name, type, index)
    {:reply, response, new_state}
  end

  @impl GenServer
  def handle_call(:get_radios, _from, ~M{radios} = state) do
    result = Map.values(radios)
    {:reply, {:ok, result}, state}
  end

  ##############################
  # Internal Calls
  ##############################

  def read_example_config do
    result =
      :elixir_honey
      |> :code.priv_dir()
      |> Path.join("samples")
      |> Path.join("config.yml")
      |> YamlElixir.read_from_file()

    case result do
      {:ok, cfg} ->
        cfg

      {:error, reason} ->
        QolUp.LoggerUtils.error(
          "Failed to parse config: #{inspect(reason, pretty: true, limit: :infinity)}"
        )

        nil
    end
  end

  def do_define_radio(~M{radios} = state, name, type, index)
      when is_number(index) and type in @known_radio_types do
    key = {type, index}
    radio = Map.get(radios, key, ~M{%Radio name: nil})

    case {radio.name, name} do
      {nil, nil} ->
        # no new data
        {state, :ok}

      {_old_name, nil} ->
        # no new data
        {state, :ok}

      {_, new_name} ->
        # update name
        radio_to_store = ~M/radio| name: new_name, type, index/
        PubSub.pub_radio_discovery(~M{%PubSub.RadioDiscovery radio: radio_to_store})
        {~M{state| radios: Map.put(radios, key, radio_to_store)}, :ok}
    end
  end

  def do_define_radio(state, _name, _type, _index), do: {state, {:error, "invalid index or type"}}

  def update_state_from_cfg(state, cfg) do
    # cfg is string-keyed from the original yaml
    cfg
    |> Map.get("systems")
    |> Enum.reduce(state, fn system, current_state ->
      name = Map.get(system, "name")

      sensors =
        system
        |> Map.get("sensors")
        |> Enum.reduce([], fn ~m{type, source} = sensor, sensor_list ->
          zones =
            sensor
            |> Map.get("zones")
            |> Enum.reduce([], fn ~m{id, name, type, perimeter} = _zone, zone_list ->
              [~M{%Zone id, name, type, perimeter} | zone_list]
            end)

          radio = ~M{%Radio name: source["name"], type: source["type"],  index: source["index"]}
          [~M{%Sensor type, source: radio, zones} | sensor_list]
        end)

      system = ~M{%System name, sensors}
      ~M{current_state| systems: Map.put(current_state.systems, name, system)}
    end)
  end
end
