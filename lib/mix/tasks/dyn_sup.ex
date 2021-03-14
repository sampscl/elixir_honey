defmodule Mix.Tasks.DynSup do
  @moduledoc """
  Create a dynamic supervisor
  """
  use Mix.Task

  @shortdoc "Creates a module-based `DynamicSupervisor`. Pass \"foo\" to make `Foo.Sup` in `lib/foo.ex`, `Foo.Worker` in `lib/foo_worker.ex"
  def run(arg) do
    :ok = generate(arg)
  end

  defp generate([sup| rest]) do
    base_module_name =
      sup
      |> Path.split()
      |> Enum.map(&(Macro.camelize(&1)))
      |> Enum.join(".")

    module_dir = Path.join("lib", Path.dirname(sup))
    File.mkdir_p!(module_dir)

    module_sup_file = "#{Path.join(module_dir, Path.basename(sup))}_sup.ex"
    module_worker_file = "#{Path.join(module_dir, Path.basename(sup))}_worker.ex"
    File.touch!(module_worker_file)

    File.open!(module_sup_file, [:write], fn(dev) -> write_sup(dev, base_module_name) end)
    File.open!(module_worker_file, [:write], fn(dev) -> write_worker(dev, base_module_name) end)

    generate(rest)
  end
  defp generate([]), do: :ok

  defp write_sup(dev, base_module_name) do
    IO.write(dev, """
    defmodule #{base_module_name}.Sup do
      @moduledoc \"\"\"
      Dynamic Supervisor
      \"\"\"

      @doc \"#{base_module_name}.Worker\"
      use DynamicSupervisor

      def start_link(init_arg_if_you_need_it) do
        DynamicSupervisor.start_link(__MODULE__, init_arg_if_you_need_it, name: __MODULE__)
      end

      @impl DynamicSupervisor
      def init(init_arg_if_you_need_it) do
        DynamicSupervisor.init(strategy: :one_for_one)
      end

      def start_child(child_init_arg_if_you_need_it) do
        # If MyWorker is not using the new child specs, we need to pass a map:
        # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar, baz]}}
        spec = {#{base_module_name}.Worker, child_init_arg_if_you_need_it}
        DynamicSupervisor.start_child(__MODULE__, spec)
      end
    end
""")
  end

  defp write_worker(dev, base_module_name) do
    IO.write(dev, """
    defmodule #{base_module_name}.Worker do
      @moduledoc \"\"\"
      Worker
      \"\"\"

      use GenServer

      ##############################
      # API
      ##############################
      def start_link(child_init_arg_if_you_need_it), do: GenServer.start_link(__MODULE__, child_init_arg_if_you_need_it)

      defmodule State do
        @moduledoc false
        defstruct [
        ]
      end

      ##############################
      # GenServer Callbacks
      ##############################

      @impl GenServer
      def init(child_init_arg_if_you_need_it) do
        {:ok, %State{}}
      end

      ##############################
      # Internal Calls
      ##############################
    end
    """)
  end
end
