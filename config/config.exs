# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ci_status, ecto_repos: [CiStatus.Repo]

import_config "#{Mix.env}.exs"
