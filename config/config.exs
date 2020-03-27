# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :hundred_points, HundredPointsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DOTjMWboP6uy4Y2C+sCUfInLnh6gbZb156w9O9e2a3FzJjQpwLxxS1bxoAnjQUg0",
  render_errors: [view: HundredPointsWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: HundredPoints.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "DyfkCSVE5fTf2TLl6nG3Y0/KPpoR6dUJkJq2Dq55jeJkZ63OxUqK6VkF6FvP8cf1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Enable writing LiveView templates with the .leex extension
config :phoenix, template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
