defmodule Rlinkx.Remote do
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo

  import Ecto.Query

  def get_link!(id) do 
    Repo.get!(Bookmark, id)
  end

  def get_all do
    Repo.all(from Bookmark, order_by: :name)
  end

  def create_link(attrs) do 
    %Bookmark{} 
    |> Bookmark.changeset(attrs)
    |> Repo.insert()
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
