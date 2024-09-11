defmodule Vhs.Transactions.Storage do
  @moduledoc """
  Stores information about pending transactions.
  """
  use GenServer

  require Logger

  @table :pending_transactions

  @notify_timeout :timer.minutes(2)

  defmodule State do
    @moduledoc false

    @enforce_keys [:flush_timer]
    defstruct [:flush_timer]

    @type t() :: %__MODULE__{
            flush_timer: :timer.tref()
          }
  end

  # API
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @doc """
  Inserts a new transaction hash in the storage.
  """
  @spec create(String.t()) :: true
  def create(tx_hash) do
    :ets.insert(@table, {tx_hash, expiration(@notify_timeout)})
  end

  @spec all :: [String.t()]
  def all do
    :ets.select(@table, [{{:"$1", :"$2"}, [], [:"$1"]}])
  end

  def delete(tx_hash) do
    :ets.delete(@table, tx_hash)
  end

  # GenServer Callbacks

  @impl GenServer
  @spec init(Keyword.t()) :: {:ok, State.t()}
  def init([]) do
    Logger.debug("creating ETS table #{@table}")

    :ets.new(@table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, flush_timer} = :timer.send_interval(@notify_timeout, :notify_old_txns)

    {:ok, %State{flush_timer: flush_timer}}
  end

  @impl GenServer
  def handle_info(:notify_old_txns, %State{} = state) do
    Logger.debug("checking for pending entries to notify about")
    # now = :erlang.system_time(:milli_seconds)
    # query = [{{'$1', '$2'}, [{'<', '$1', {:const, now}}], ['$2']}]
    # _older_entries = :ets.select(@table, query)
    # XXX: Spawn task to notify Slack about the above entries
    {:noreply, state}
  end

  defp expiration(ttl), do: :erlang.system_time(:milli_seconds) + ttl
end
