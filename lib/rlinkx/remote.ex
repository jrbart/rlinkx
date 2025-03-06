defmodule Rlinkx.Remote do
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.{Insight, Bookmark}
  alias Rlinkx.Repo

  import Ecto.Query

  def get_link!(id) do 
    Repo.get!(Bookmark, id)
  end

  def get_all do
    Repo.all(from Bookmark, order_by: :name)
  end

  def list_all_insights(%Bookmark{id: bookmark_id}) do
    Insight
    |> where([i], i.bookmark_id == ^bookmark_id)
    |> order_by([i], asc: :inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()
  end

  # TODO this should be insight, not link...
  def changeset_link(link, attrs \\ %{}) do
    Insight.changeset(link, attrs)
  end

  # TODO this should be insight, not link...
  def create_link(link, user, attrs) do 
    %Insight{bookmark: link, user: user} 
    |> Insight.changeset(attrs)
    |> Repo.insert()
  end

  def delete_insight(id, %User{id: user_id}) do
    insight = Repo.get!(Insight,id, preload: :user)
    if insight.user_id  == user_id do
      Repo.delete!(insight)
    end

  end

  def update_link(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end

  def change_link(link, attrs \\ %{}) do
    Bookmark.changeset(link, attrs)
  end
end
