# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ash, custom_types: [search_query: AshDemo.Type.SearchQuery]

config :ash_demo, AshDemo.Mailer, adapter: Swoosh.Adapters.Local

config :ash_demo, AshDemoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AshDemoWeb.ErrorHTML, json: AshDemoWeb.ErrorJSON],
    layout: false
  ],

  # Configures the mailer
  #
  # By default it uses the "Local" adapter which stores the emails
  # locally. You can see the emails in your browser, at "/dev/mailbox".
  #
  # For production it's recommended to configure a different adapter
  # at the `config/runtime.exs`.
  pubsub_server: AshDemo.PubSub,
  live_view: [signing_salt: "DJVzQ41B"]

config :ash_demo,
  ecto_repos: [AshDemo.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [AshDemo.Blog],
  base_resources: [AshDemo.Search.Filter]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Configures the endpoint

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  ash_demo: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :postgres,
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [section_order: [:resources, :policies, :authorization, :domain, :execution]]
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  ash_demo: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),

    # Import environment specific config. This must remain at the bottom
    # of this file so it overrides the configuration defined above.
    cd: Path.expand("../assets", __DIR__)
  ]

import_config "#{config_env()}.exs"
