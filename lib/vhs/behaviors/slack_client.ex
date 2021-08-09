defmodule Vhs.Behaviors.SlackClient do
  @moduledoc false

  @type request_response :: {:ok, response :: String.t()} | {:error, response :: String.t()}

  @callback webhook_post(chain_response :: map()) :: request_response()
end
