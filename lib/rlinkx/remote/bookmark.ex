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
    |> validate_required([:name, :url_link])
    |> validate_length(:name, max: 80)
    |> validate_format(:name, ~r/[[:alnum:]-]+/,
      message: "can only contain alphanumeric characters and dashes"
    )
    |> validate_length(:description, max: 200)
    |> validate_change(:url_link, &uri_validator/2)
  end

  defp uri_validator(:url_link, _url) do
    # [url_link: {"not a valid url", atom: "error"}]
    # use URI.new() to parse url and check:
    #  scheme is either "http" or "https"
    #  host is not nil
    IO.puts("Validating change")
    []
  end
end
