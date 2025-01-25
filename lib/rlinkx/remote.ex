defmodule Rlinkx.Remote do
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo

  import Ecto.Query

  def get_all do
    Repo.all(from Bookmark, order_by: :name)
  end
  
end
