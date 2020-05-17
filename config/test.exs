use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :app, App.Repo,
  username: "postgres",
  password: "postgres",
  database: "admin_zone_1_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("PG_HOST") || "localhost",
  port: String.to_integer(System.get_env("PG_PORT") || "5432"),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :app, AppWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :app, App.Guardian, secret_key: "TestSecretKey"

config :app, App.Mailer, adapter: Bamboo.TestAdapter
