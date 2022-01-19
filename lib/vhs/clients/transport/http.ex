defmodule Vhs.Clients.Transport.HTTP do
  @moduledoc """
  Base HTTP client interface.

  ### Options

  * `:base_url` - `String.t()` Base URL, e.g. "https://someurl.com"

  ### Usage

      defmodule Vhs.MyClient do
        use Vhs.Clients.Transport.HTTP,
          base_url: "https://someapi.com"

        plug Tesla.Middleware.Something
      end

  You can set the adapter from configuration like the line below, this allows
   for easier overriding in tests:

    config :tesla, Vhs.MyClient, adapter: Tesla.Adapter.Mint
  """

  @type option :: {:base_url, String.t()}

  @spec __using__(options :: [option()]) :: Macro.t()
  defmacro __using__(options) do
    base_url = Keyword.fetch!(options, :base_url)

    quote do
      use Tesla

      plug(Tesla.Middleware.BaseUrl, unquote(base_url))
      plug(Tesla.Middleware.Logger, debug: false)
      plug(Tesla.Middleware.JSON, engine: Jason)
    end
  end
end
