defmodule Vhs.HTTP do
  @moduledoc """
  Interface to use any HTTP client. 
  """

  @http_client Application.compile_env(:vhs, :http_client)

  def post(body, opts \\ []) do
    # Usually in `opts` you'll receive the client configuration, which can be ignored or can
    # be used to construct the body of the request, append authorization to headers, or simply
    # get ignored, up to you.
    @http_client.post(body, opts)
  end
end
