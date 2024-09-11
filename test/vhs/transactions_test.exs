defmodule Vhs.TransactionsTest do
  @moduledoc false
  use ExUnit.Case

  alias Vhs.Clients.SlackMock
  alias Vhs.Transactions
  alias Vhs.Transactions.Storage

  import Mox
  import Vhs.TestUtils

  setup [:clean_transactions]

  describe "create/1" do
    test "fails on invalid payload" do
      assert Transactions.create(%{"foo" => "bar"}) == {:error, :missing_hashes}
      assert Transactions.create(%{"hashes" => "1"}) == {:error, :invalid_data}
    end

    test "can create a single transaction" do
      mock_blocknative_watch()
      assert Transactions.create(%{"hashes" => ["hash1"]}) == %{ok: ["hash1"]}
    end

    test "can create multiple transactions" do
      hashes = ["h1", "h2", "h3"]
      mock_blocknative_watch(length(hashes))
      assert Transactions.create(%{"hashes" => hashes}) == %{ok: hashes}
    end
  end

  describe "all/0" do
    test "returns empty list when no transaction are pending" do
      assert Transactions.all() == []
    end

    test "returns list of pending transactions" do
      hashes = ["h1", "h2", "h3"]
      mock_blocknative_watch(length(hashes))
      Transactions.create(%{"hashes" => hashes})

      assert Transactions.all() == hashes
    end
  end

  describe "confirm/1" do
    test "sends Slack message and removes pending transaction" do
      hash = "spammenowbaby"

      # Mock Slack call
      SlackMock
      |> expect(:call, fn %{
                            method: :post,
                            url:
                              "https://hooks.slack.com/services/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",
                            body: body
                          },
                          _opts ->
        assert String.contains?(body, "*Status: Done*")
        assert String.contains?(body, hash)
        {:ok, %Tesla.Env{status: 200}}
      end)

      Storage.create(hash)

      assert [^hash] = Transactions.all()
      assert {:ok, %{status: 200}} = Transactions.confirm(%{"hash" => hash, "status" => "done"})
      assert Transactions.all() == []
    end

    test "keeps pending transaction if Slack fails" do
      # Hoping blocknative retries on webhook errors (non-2xx)
      # Otherwise a good strategy here will be to use
      # a Retry strategy in the HTTP client.
      hash = "bogustx"

      # Mock Slack call
      SlackMock
      |> expect(:call, fn %{
                            method: :post,
                            url:
                              "https://hooks.slack.com/services/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",
                            body: body
                          },
                          _opts ->
        assert String.contains?(body, hash)
        {:ok, %Tesla.Env{status: 400}}
      end)

      Storage.create(hash)

      assert Transactions.all() == [hash]
      assert {:error, :slack_error} = Transactions.confirm(%{"hash" => hash, "status" => "done"})
      assert Transactions.all() == [hash]
    end
  end
end
