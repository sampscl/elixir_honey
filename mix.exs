defmodule ElixirHoney.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_honey,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
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
      test: "test --no-start",
      espec: "espec --no-start",
    ]
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
      # {:flub, "~> 1.1"},
      {:flub, git: "https://github.com/sampscl/flub.git", branch: "master"},
      {:line_buffer, "~> 1.0"},
    ]
  end
end
