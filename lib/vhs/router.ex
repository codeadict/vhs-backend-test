defmodule Vhs.Router do
  @moduledoc """
  Main router of the application to handle incoming requests
  """

  use Plug.Router

  require Logger

  alias Plug.Conn.Status
  alias Vhs.Transactions

  plug(Plug.RequestId)
  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  get "/_health" do
    {:ok, version} = :application.get_key(:vhs, :vsn)

    send_json_resp(conn, 200, wrap_data(%{version: List.to_string(version)}))
  end

  post "/transactions" do
    handle_create(conn, Transactions.create(conn.body_params))
  end

  get "/transactions/pending" do
    send_json_resp(conn, 200, wrap_data(%{hashes: Transactions.all()}))
  end

  post "/blocknative/confirm" do
    case Transactions.confirm(conn.body_params) do
      {:ok, _} ->
        send_json_resp(conn, 200, wrap_data(%{status: "ok"}))

      _ ->
        # This is logged on Slack's client
        send_json_resp(conn, 422, %{errors: ["there was an error posting to slack"]})
    end
  end

  match _ do
    send_json_resp(conn, 404, %{error: Status.reason_phrase(404)})
  end

  defp send_json_resp(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
    |> halt()
  end

  defp wrap_data(body), do: %{data: body}

  defp handle_create(conn, %{ok: hashes, error: errors}) do
    response =
      %{hashes: hashes}
      |> wrap_data()
      |> Map.merge(%{errors: errors})

    send_json_resp(conn, 207, response)
  end

  defp handle_create(conn, %{ok: hashes}),
    do: send_json_resp(conn, 200, wrap_data(%{hashes: hashes}))

  defp handle_create(conn, %{error: errors}) when is_list(errors),
    do: send_json_resp(conn, 500, %{errors: errors})

  defp handle_create(conn, {:error, :missing_hashes}),
    do: send_json_resp(conn, 422, %{errors: [%{hashes: "is required"}]})

  defp handle_create(conn, _error),
    do: send_json_resp(conn, 422, %{errors: ["cannot create transactions"]})
end
