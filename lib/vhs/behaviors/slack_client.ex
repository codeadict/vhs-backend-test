defmodule Vhs.Behaviors.SlackClient do
  @moduledoc false

  @type request_response :: {:ok, response :: String.t()} | {:error, response :: String.t()}

  @callback webhook_post(request_body :: map()) :: request_response()
  @callback client_config() :: map()
end
