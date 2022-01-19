import Config

if config_env() == :test do
  config :tesla, Vhs.Clients.Blocknative, adapter: Vhs.Clients.BlocknativeMock
  config :tesla, Vhs.Clients.Slack, adapter: Vhs.Clients.SlackMock
end

# Set the `:username` config value here with your Name or Github handler.
config :vhs,
  blocknative: %{
    api_key: System.fetch_env!("BLOCKNATIVE_API_KEY"),
    blockchain: System.get_env("BLOCKNATIVE_BLOCKCHAIN", "ethereum"),
    network: System.get_env("BLOCKNATIVE_NETWORK", "main")
  },
  slack: %{
    webhook_key: System.fetch_env!("SLACK_WEBHOOK_KEY")
  }
