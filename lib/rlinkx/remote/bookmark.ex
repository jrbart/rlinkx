defmodule Rlinkx.Remote.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :name, :string
    field :description, :string
    field :url_link, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:name, :description, :url_link])
    |> validate_required([:name, :description, :url_link])
  end
end
