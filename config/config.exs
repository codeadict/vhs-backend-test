import Config

config :vhs,
  blocknative: %{
    api_key: nil,
    blockchain: "ethereum",
    network: "main",
    base_url: "https://api.blocknative.com"
  },
  slack: %{
    base_url: "https://hooks.slack.com/services",
    webhook_key: nil
  }

