use Mix.Config

config :ci_status, CiStatus.Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "ci_statuses",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :ci_status, port: 80
config :ci_status, shields_url: "https://img.shields.io"

import_config "prod.secret.exs"
