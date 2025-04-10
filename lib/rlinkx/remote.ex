defmodule Rlinkx.Remote do
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.Insight
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo
  alias Rlinkx.Remote.UsersBookmarks

  import Ecto.Query

  @pubsub Rlinkx.PubSub

  def get_link!(id) do
    Repo.get!(Bookmark, id)
  end

  def get_followed_links(%User{} = user) do
    user
    |> Repo.preload(:bookmarks)
    |> Map.fetch!(:bookmarks)
    |> Enum.sort_by(& &1.name)
  end

  def get_all do
    Repo.all(from Bookmark, order_by: :name)
  end

  def following?(%Bookmark{} = bookmark, %User{} = user) do
    Repo.exists?(
      from ub in UsersBookmarks, where: ub.bookmark_id == ^bookmark.id and ub.user_id == ^user.id
    )
  end

  def list_all_insights(%Bookmark{id: bookmark_id}) do
    Insight
    |> where([i], i.bookmark_id == ^bookmark_id)
    |> order_by([i], asc: :inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()
  end

  def changeset_insight(link, attrs \\ %{}) do
    Insight.changeset(link, attrs)
  end

  def create_insight(link, user, attrs) do
    with {:ok, insight} <-
           %Insight{bookmark: link, user: user}
           |> Insight.changeset(attrs)
           |> Repo.insert() do
      Phoenix.PubSub.broadcast!(@pubsub, topic(link.id), {:insight_created, insight})
      {:ok, insight}
    end
  end

  def delete_insight(id, %User{id: user_id}) do
    insight = Repo.get!(Insight, id, preload: :user)

    if insight.user_id == user_id do
      Repo.delete!(insight)
      Phoenix.PubSub.broadcast!(@pubsub, topic(insight.bookmark_id), {:insight_deleted, insight})
    end
  end

  def follow_bookmark(bookmark, user) do
    Repo.insert!(%UsersBookmarks{bookmark: bookmark, user: user})
  end

  def update_link(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end

  def change_link(link, attrs \\ %{}) do
    Bookmark.changeset(link, attrs)
  end

  def subscribe_to_link(bookmark) do
    Phoenix.PubSub.subscribe(@pubsub, topic(bookmark.id))
  end

  def unsubscribe_to_link(bookmark) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(bookmark.id))
  end

  defp topic(topic) do
    "insight:#{topic}"
  end
end
