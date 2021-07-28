defmodule Vhs.Clients.Slack do
  @moduledoc """
  Interface to communicate with Slack through a webhook

  Ideally the client_config will return api keys or anything else to custommize the request.
  """

  @behaviour Vhs.Behavior.SlackClient

  alias Vhs.Client

  @impl true
  def webhook_post(body) do
    config = client_config()

    case Vhs.HTTP.post(body, client_config: config) do
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
