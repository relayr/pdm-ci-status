defmodule CiStatus.Db.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:ci_statuses, primary_key: false) do
      add :type, :string, primary_key: true
      add :name, :string, primary_key: true
      add :version, :string, primary_key: true
      add :link, :string
      add :badge_text, :string
      add :badge_color, :string
    end
  end
end
