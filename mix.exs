defmodule Vhs.MixProject do
  use Mix.Project

  def project do
    [
      app: :vhs,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_options: [warnings_as_errors: true]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Vhs.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:gun, "~> 1.3"},
      {:jason, "~> 1.2"},
      {:idna, "~> 6.0"},
      {:castore, "~> 0.1"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
