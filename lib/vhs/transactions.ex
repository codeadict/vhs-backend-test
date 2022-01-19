defmodule Vhs.Transactions do
  @moduledoc """
  Manages pending blockchain transaction.
  """

  require Logger

  alias Vhs.Clients.Blocknative
  alias Vhs.Clients.Slack
  alias Vhs.Transactions.Storage

  @type hash :: String.t()

  @doc """
  Creates a new pending transaction.term()

  The transaction is sent to Blocknative to notify back on status changes
   and kept in a local storage until the transaction is confirmed.
  """
  @spec create(%{required(String.t()) => [hash()]}) ::
          %{
            optional(:ok) => [hash()],
            optional(:error) => [any()]
          }
          | {:error, any()}
  def create(params) do
    with {:ok, hashes} <- validate_tx_hashes(params) do
      hashes
      |> Task.async_stream(&watch_and_store(&1), on_timeout: :kill_task)
      |> Enum.group_by(
        fn {:ok, {res, _val}} -> res end,
        fn {:ok, {_res, val}} -> val end
      )
    end
  end

  @doc """
  Lists all the stored pending transactions
  """
  @spec all() :: [hash()]
  defdelegate all, to: Storage

  @doc """
  Confirms an existing transaction as completed and posts message to Slack.
  """
  @spec confirm(map) :: {:ok, Tesla.Env.t()} | {:error, any}
  def confirm(params) do
    Logger.info("#{params["hash"]} got mined")

    with {:ok, resp} <- Slack.webhook_post(params),
         true <- Storage.delete(params["hash"]) do
      {:ok, resp}
    end
  end

  defp watch_and_store(tx_hash) do
    with {:ok, _response} <- Blocknative.watch_tx(%{hash: tx_hash}),
         true <- Storage.create(tx_hash) do
      {:ok, tx_hash}
    else
      {:error, reason} = error ->
        Logger.error("unable to create transaction #{tx_hash}", reason: reason)
        error
    end
  end

  defp validate_tx_hashes(params) when is_map(params) and is_map_key(params, "hashes") do
    case Access.get(params, "hashes") do
      nil -> {:error, :missing_hashes}
      hashes when is_list(hashes) -> {:ok, hashes}
      _other -> {:error, :invalid_data}
    end
  end

  defp validate_tx_hashes(_params), do: {:error, :missing_hashes}
end
