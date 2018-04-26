use Mix.Config

config :ci_status, CiStatus.Db.Repo,
  adapter: Sqlite.Ecto2,
  database: "ci_status.sqlite3"

config :ci_status, port: 8880
