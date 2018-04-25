use Mix.Config

config :ci_status, CiStatus.Repo,
  adapter: Sqlite.Ecto2,
  database: "ci_statuses.sqlite3"

config :ci_status, port: 8880
