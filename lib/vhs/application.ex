defmodule Vhs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Vhs.Transactions.Storage, []},
      {Plug.Cowboy, scheme: :http, plug: Vhs.Router, options: [port: port()]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vhs.Supervisor]

    Logger.info("VHS test listening on port #{port()}...")
    Supervisor.start_link(children, opts)
  end

  defp port do
    :vhs
    |> Application.get_env(Vhs.Router, port: 4000)
    |> Keyword.get(:port)
  end
end
