defmodule Mix.Tasks.Sup do
  @moduledoc """
  Create a supervisor
  """
  use Mix.Task

  @shortdoc "Creates a module-based `Supervisor`. Pass \"lib/foo\" to make `Foo.Sup` in `lib/foo.ex`"
  def run(arg) do
    IO.puts(inspect(arg, pretty: true, limit: :infinity))
    IO.puts("cwd: #{File.cwd!()}")
  end
end
