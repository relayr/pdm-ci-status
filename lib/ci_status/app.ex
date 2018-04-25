defmodule CiStatus.App do
  use Application

  def start(_type, _args) do
    CiStatus.Supervisor.start_link(name: CiStatus.Supervisor)
  end
end