defmodule Rlinkx.Remote.UsersBookmarks do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Rlinkx.Repo

  alias __MODULE__
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Remote.Insight

  schema "users_bookmarks" do
    belongs_to :user, User
    belongs_to :bookmark, Bookmark

    field :last_read_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(users_bookmarks, attrs) do
    users_bookmarks
    |> cast(attrs, [])
    |> validate_required([])
  end

  def get_following(%User{} = user, %Bookmark{} = bookmark) do
    Repo.get_by(UsersBookmarks, user_id: user.id, bookmark_id: bookmark.id)
  end

  def update_last_read(%UsersBookmarks{} = user_bookmark) do
    timestamp =
      from(i in Insight,
        where: i.bookmark_id == ^user_bookmark.bookmark_id,
        select: max(i.inserted_at)
      )
      |> Repo.one()

    user_bookmark
    |> change(last_read_at: timestamp)
    |> Repo.update()

    timestamp
  end
end
