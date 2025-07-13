defmodule Rlinkx.Remote.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rlinkx.Remote.Insight
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.UsersBookmarks

  schema "bookmarks" do
    field :name, :string
    field :description, :string
    field :url_link, :string

    belongs_to :owner, User

    many_to_many :users, User, join_through: UsersBookmarks

    # explicitly expose followers from join table
    # so we can count unread messages from other users
    has_many :followers, UsersBookmarks
    has_many :insights, Insight

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:name, :description, :url_link, :owner_id])
    |> validate_required([:name, :url_link, :owner_id])
    |> validate_length(:name, max: 20)
    |> validate_format(:name, ~r/\A[[:alnum:]_-]+\z/,
      message: "can only contain alphanumeric characters, dashes and underscores"
    )
    |> unsafe_validate_unique(:name, Rlinkx.Repo)
    |> unique_constraint(:name)
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
