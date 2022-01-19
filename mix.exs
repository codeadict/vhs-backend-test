defmodule Vhs.MixProject do
  use Mix.Project

  def project do
    [
      app: :vhs,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      elixirc_options: [warnings_as_errors: true]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Vhs.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:mint, "~> 1.0"},
      {:jason, "~> 1.3"},
      {:idna, "~> 6.0"},
      {:castore, "~> 0.1"},
      {:plug, "~> 1.12"},
      {:plug_cowboy, "~> 2.5"},
      # Development and testing dependencies
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: [:test, :dev]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix serve
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      serve: ["run --no-halt"]
    ]
  end
end
