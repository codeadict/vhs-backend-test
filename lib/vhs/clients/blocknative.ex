defmodule Vhs.Clients.Blocknative do
  @moduledoc """
  Interface to communicate with Blocknative's API

  Ideally the client_config will return api keys, network, etc...
  """
  require Logger

  use Vhs.Clients.Transport.HTTP, base_url: "https://api.blocknative.com"

  @spec watch_tx(request_body :: map()) :: Tesla.Env.result()
  def watch_tx(body) do
    body = build_watch_tx_body(body)

    case post("/transaction", body) do
      {:ok, %Tesla.Env{status: status} = resp} when status in 200..201 ->
        {:ok, resp}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        reason = Access.get(body, "msg", body)

        Logger.error(
          "Received #{status} error trying to watch #{inspect(body.hash)} with reason #{inspect(reason)}"
        )

        {:error, :client_error}

      {:error, error} ->
        Logger.error(
          "Received error trying to watch #{inspect(body.hash)} with reason #{inspect(error)}"
        )

        {:error, error}
    end
  end

  defp build_watch_tx_body(body) do
    config = Application.get_env(:vhs, :blocknative)

    Map.merge(
      %{
        "apiKey" => config[:api_key],
        "blockchain" => config[:blockchain],
        "network" => config[:network]
      },
      body
    )
  end
end
