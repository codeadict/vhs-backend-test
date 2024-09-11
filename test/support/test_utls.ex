defmodule Vhs.TestUtils do
  @moduledoc """
  This module defines common utilities for tests.
  """
  import ExUnit.Assertions
  import Mox

  alias Plug.Conn
  alias Vhs.Clients.BlocknativeMock

  def clean_transactions(context) do
    # Cleanup transaction cache between runs
    :ets.delete_all_objects(:pending_transactions)
    {:ok, context}
  end

  def mock_blocknative_watch(
        num_calls \\ 1,
        expected_resp \\ {:ok, %Tesla.Env{status: 200, body: "ok"}}
      ) do
    BlocknativeMock
    |> expect(:call, num_calls, fn %{
                                     method: :post,
                                     url: "https://api.blocknative.com/transaction"
                                   },
                                   _opts ->
      expected_resp
    end)
  end

  def assert_response(
        conn,
        exp_status,
        exp_body,
        exp_headers \\ [],
        decode_body_fn \\ fn x -> Jason.decode!(x) end
      ) do
    assert conn.status == exp_status
    assert decode_body_fn.(conn.resp_body) == exp_body

    for {name, value} <- exp_headers do
      clean_value = Conn.get_resp_header(conn, name)
      assert {name, clean_value} == {name, [value]}
    end
  end
end
