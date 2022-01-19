defmodule Vhs.Clients.Slack do
  @moduledoc """
  Interface to communicate with Slack through a webhook

  Ideally the client_config will return api keys or anything else to custommize the request.
  """
  require Logger

  use Vhs.Clients.Transport.HTTP, base_url: "https://hooks.slack.com/services"

  @caller Application.compile_env!(:vhs, :username)

  @spec webhook_post(map()) :: Tesla.Env.result()
  def webhook_post(chain_response) do
    config = Application.get_env(:vhs, :slack)
    body = build_body(chain_response)

    case post(config.webhook_key, body) do
      {:ok, %Tesla.Env{status: status} = resp} when status in 200..201 ->
        {:ok, resp}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        Logger.error(
          "Received #{status} error trying to post to Slack with response #{inspect(body)}"
        )

        {:error, :slack_error}

      {:error, error} ->
        Logger.error("Received error trying to post to Slack with reason #{inspect(error)}")

        {:error, error}
    end
  end

  defp build_body(chain_response) do
    hash = Access.get(chain_response, "hash")

    status =
      chain_response
      |> Access.get("status", "")
      |> String.capitalize()

    %{
      text: "*#{hash} got mined*",
      attachments: [
        %{
          blocks: [
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "*From: #{@caller}*"
              }
            },
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "*Status: #{status}*"
              }
            },
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "*See on*"
              }
            },
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "<https://etherscan.com/tx/#{hash}|Etherscan> :male-detective:"
              }
            }
          ]
        }
      ]
    }
  end
end
