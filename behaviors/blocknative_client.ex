defmodule Vhs.Behaviors.BlocknativeClient do
  @moduledoc false

  @type request_response :: {:ok, response :: String.t()} | {:error, response :: String.t()}

  @callback watch_tx(request_body :: map()) :: request_response()
  @callback client_config() :: map()
  @callback watch_address(request_body :: map()) :: request_response()
  @callback stop_watching_tx(request_body :: map()) :: request_response()

  @optional_callbacks [stop_watching_tx: 2, watch_address: 2]
end
