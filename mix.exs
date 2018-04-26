defmodule CiStatus.MixProject do
  use Mix.Project

  def project do
    [
      app: :ci_status,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    db_engine = case Mix.env() do
      :prod -> :postgrex
      _ -> :sqlite_ecto2
    end
    [
      applications: [:logger, db_engine, :ecto, :cowboy, :plug],
      mod: {CiStatus.App, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    db_app = case Mix.env() do
      :prod -> {:postgrex, "~> 0.13"}
      _ -> {:sqlite_ecto2, "~> 2.2"}
    end
    [
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      db_app,
      {:ecto, "~> 2.2"},
      {:poison, "~> 3.1"}
    ]
  end
end
