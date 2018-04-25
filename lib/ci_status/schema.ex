defmodule CiStatus.Schema do
  use Ecto.Schema

  @primary_key false
  schema "ci_statuses" do
    field :type, :string
    field :name, :string
    field :link, :string
    field :badge_text, :string
    field :badge_color, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
      |> Ecto.Changeset.cast(params, [:link, :badge_text, :badge_color])
  end
end

