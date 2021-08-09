defmodule Vhs.Clients.Slack do
  @moduledoc """
  Interface to communicate with Slack through a webhook

  Ideally the client_config will return api keys or anything else to custommize the request.
  """

  require Logger

  @behaviour Vhs.Behaviors.SlackClient

  @client_config Application.compile_env!(:vhs, :slack)

  @impl true
  def webhook_post(chain_response) do
    body = %{
      text: "*#{chain_response["hash"]} got mined*",
      attachments: [
        %{
          blocks: [
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "*Status: #{String.capitalize(chain_response["status"])}*"
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
                text:
                  "<https://etherscan.com/tx/#{chain_response["hash"]}|Etherscan> :male-detective:"
              }
            }
          ]
        }
      ]
    }

    case Vhs.HTTP.post(@client_config.webhook_key, body, @client_config) do
      {:ok, response} ->
        {:ok, response}

      {:error, error} ->
        Logger.error("Received error trying to post to Slack with reason #{inspect(error)}")

        {:error, error}
    end
  end
end
