defmodule ElixirHoney.MixProject do
  use Mix.Project

  @doc """
  Get the version of the app. This will do sorta-smart things when git is not
  present on the build machine (it's possible, especially in Docker containers!)
  by using the "version" environment variable.

  ## Returns
  - version `String.t`
  """
  def version do
    "git describe"
    |> System.shell(cd: Path.dirname(__ENV__.file))
    |> then(fn
      {version, 0} -> Regex.replace(~r/^[[:alpha:]]*/, String.trim(version), "")
      {_barf, _exit_code} -> System.get_env("version", "0.0.0-UNKNOWN")
    end)
    |> tap(&IO.puts("Version: #{&1}"))
  end

  def project do
    [
      app: :elixir_honey,
      version: version(),
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [espec: :test],
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :sasl],
      mod: {ElixirHoney.Application, []}
    ]
  end

  def aliases do
    [
      espec: &espec/1
    ]
  end

  def espec(args) do
    Mix.Task.run("espec", args ++ ["--no-start"])
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:espec, "~> 1.8", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:poison, "~> 4.0"},
      {:jason, "~> 1.0"},
      {:logger_file_backend, "~>0.0.11"},
      {:executus, "~>0.6"},
      {:shorter_maps, "~>2.2"},
      {:cowboy, "~> 2.6"},
      {:plug, "~> 1.4"},
      {:plug_cowboy, "~> 2.0"},
      {:hexate, "~> 0.6"},
      {:timex, "~> 3.6"},
      {:yaml_elixir, "~> 2.5"},
      {:absinthe_plug, "~> 1.5"},
      {:flub, git: "https://github.com/sampscl/flub.git", branch: "master"},
      {:line_buffer, "~> 1.0"},
      {:qol_up, "~>1.1"}
    ]
  end
end
