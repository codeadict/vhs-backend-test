defmodule Vhs.Router do
  @moduledoc """
  Main router of the application to handle incoming requests
  """

  use Plug.Router

  alias Vhs.Clients.Slack

  require Logger

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  post "/blocknative/confirm" do
    Logger.info("#{conn.body_params["hash"]} got mined")

    case Slack.webhook_post(conn.body_params) do
      {:ok, _} ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(200, Jason.encode!(%{status: "ok"}))
        |> send_resp()

      {:error, _error} ->
        # This is logged on Slack's client
        conn
        |> put_resp_content_type("application/json")
        |> resp(422, Jason.encode!(%{error: "there was an error posting to slack"}))
        |> send_resp()
    end
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> resp(404, Jason.encode!(%{error: "not found"}))
    |> send_resp()
  end
end
