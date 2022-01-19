import Config

config :vhs,
  username: "Dairon Medina Caro <codeadict>"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Set global adapter for Tesla
config :tesla, :adapter, Tesla.Adapter.Mint
