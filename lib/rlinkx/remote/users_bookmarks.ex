defmodule Rlinkx.Remote.UsersBookmarks do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.Bookmark

  schema "users_bookmarks" do
    belongs_to :user, User
    belongs_to :bookmark, Bookmark

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(users_bookmarks, attrs) do
    users_bookmarks
    |> cast(attrs, [])
    |> validate_required([])
  end
end
