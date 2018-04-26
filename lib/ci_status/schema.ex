defmodule CiStatus.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "ci_statuses" do
    field :type, :string, primary_key: true
    field :name, :string, primary_key: true
    field :link, :string
    field :badge_text, :string
    field :badge_color, :string
  end

  def changeset(struct, params \\ %{}) do
    required_params = [:link, :badge_text, :badge_color]
    struct
    |> cast(params, required_params)
    |> validate_required(required_params)
    |> validate_url(:link)
  end

  @doc """
    validates field is a valid url

    ## Examples
      iex> Ecto.Changeset.cast(%CiStatus.Schema{}, %{"link" => "https://www.zipbooks.com"}, [:link])
      ...> |> CiStatus.Schema.validate_url(:link)
      ...> |> Map.get(:valid?)
      true

      iex> Ecto.Changeset.cast(%CiStatus.Schema{}, %{"link" => "http://zipbooks.com/"}, [:link])
      ...> |> CiStatus.Schema.validate_url(:link)
      ...> |> Map.get(:valid?)
      true

      iex> Ecto.Changeset.cast(%CiStatus.Schema{}, %{"link" => "zipbooks.com"}, [:link])
      ...> |> CiStatus.Schema.validate_url(:link)
      ...> |> Map.get(:valid?)
      false
    """
  def validate_url(changeset, field, opts \\ []) do
    validate_change changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: nil} -> "is missing a scheme (e.g. https)"
        %URI{host: nil} -> "is missing a host"
        %URI{} -> nil
      end
      |> case do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end
  end
end

