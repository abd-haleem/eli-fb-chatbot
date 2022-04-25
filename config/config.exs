# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :chatbot,
  ecto_repos: [Chatbot.Repo]

# Configures the endpoint
config :chatbot, ChatbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TGG271cY089ctqyE9yA6jJqPVJKMekm27LucPjZexQL+wcY+5TZiW1PMe78lUIEV",
  render_errors: [view: ChatbotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Chatbot.PubSub,
  live_view: [signing_salt: "gY/eEb8D"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :chatbot,
  facebook_page_token: System.get_env("FACEBOOK_PAGE_TOKEN", "undefined")

config :chatbot,
  facebook_verify_token: System.get_env("FACEBOOK_VERIFY_TOKEN", "undefined")


# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
