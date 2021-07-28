defmodule Vhs.Clients.Blocknative do
  @moduledoc """
  Interface to communicate with Blocknative's API

  Ideally the client_config will return api keys, network, etc...
  """

  @behaviour Vhs.Behaviors.BlocknativeClient

  @impl true
  def watch_tx(body) do
    config = client_config()

    case Vhs.Clients.HTTP.post(body, client_config: config) do
      {:ok, _} ->
        :ok?

      {:error, _} ->
        :error?
    end
  end

  @impl true
  def client_config do
    %{}
  end
end
