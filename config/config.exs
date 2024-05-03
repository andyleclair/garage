# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :garage,
  ecto_repos: [Garage.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :garage, GarageWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GarageWeb.ErrorHTML, json: GarageWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Garage.PubSub,
  live_view: [signing_salt: "bViCUv7u"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :garage, Garage.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --external:/js/service-worker.js),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_aws,
  http_client: ExAws.Finch,
  json_codec: Jason

config :garage,
  ash_domains: [Garage.Builds, Garage.Mopeds, Garage.Accounts],
  env: config_env()

# config :crawly,
#  closespider_timeout: 10,
#  concurrent_requests_per_domain: 8,
#  closespider_itemcount: 100,
#  middlewares: [
#    Crawly.Middlewares.DomainFilter,
#    Crawly.Middlewares.UniqueRequest,
#    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]}
#  ],
#  pipelines: [
#    {Crawly.Pipelines.Validate, fields: [:name]},
#    {Crawly.Pipelines.DuplicatesFilter, item_id: :name},
#    Crawly.Pipelines.JSONEncoder,
#    {Crawly.Pipelines.WriteToFile,
#     extension: "ndjson", folder: Path.join(["priv", "repo", "seeds", "spider_output"])}
#  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
