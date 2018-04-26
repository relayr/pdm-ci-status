defmodule CiStatus.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    port = Application.get_env(:ci_status, :port)
    children = [
      CiStatus.Db.Repo,
      Plug.Adapters.Cowboy.child_spec(:http, CiStatus.Web, [], port: port)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end