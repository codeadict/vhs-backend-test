defmodule Vhs.RouterTest do
  @moduledoc false

  use ExUnit.Case

  alias Vhs.Router
  alias Vhs.Transactions

  import Plug.Test
  import Vhs.TestUtils

  describe "POST /transactions" do
    setup [:clean_transactions]

    test "can handle a single transaction" do
      mock_blocknative_watch()

      :post
      |> conn("/transactions", %{"hashes" => ["foo"]})
      |> Router.call([])
      |> assert_response(200, %{"data" => %{"hashes" => ["foo"]}})

      assert ["foo"] == Transactions.all()
    end

    test "can handle multiple transactions" do
      transaction_hashes = ["foo", "bar", "baz"]
      num_calls = length(transaction_hashes)

      mock_blocknative_watch(num_calls)

      :post
      |> conn("/transactions", %{"hashes" => transaction_hashes})
      |> Router.call([])
      |> assert_response(200, %{"data" => %{"hashes" => transaction_hashes}})

      assert transaction_hashes == Transactions.all()
    end
  end

  describe "GET /transactions/pending" do
    setup [:clean_transactions]

    test "no transactions returns empty list" do
      :get
      |> conn("/transactions/pending")
      |> Router.call([])
      |> assert_response(200, %{"data" => %{"hashes" => []}})
    end

    test "returns a list of stored transactions" do
      hashes = ["tx1", "tx2", "tx3", "txn"]
      mock_blocknative_watch(length(hashes))

      %{ok: transactions} = Transactions.create(%{"hashes" => hashes})

      conn =
        :get
        |> conn("/transactions/pending")
        |> Router.call([])

      received_transactions =
        conn.resp_body
        |> Jason.decode!()
        |> get_in(["data", "hashes"])
        |> Enum.sort()

      assert conn.status == 200
      assert received_transactions == transactions
    end
  end

  describe "GET /_health" do
    test "returns 200" do
      version = Application.spec(:vhs, :vsn) |> List.to_string()

      :get
      |> conn("/_health")
      |> Router.call([])
      |> assert_response(200, %{"data" => %{"version" => version}})
    end
  end

  describe "API Error handling" do
    test "renders 404 for unknown endpoints" do
      :get
      |> conn("/transactions/fakeurl")
      |> Router.call([])
      |> assert_response(404, %{"error" => "Not Found"})
    end
  end
end
