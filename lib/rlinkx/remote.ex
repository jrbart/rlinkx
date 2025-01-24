defmodule Rlinkx.Remote do
  alias Rlinkx.Remote.Bookmark
  alias Rlinkx.Repo

  def get_all do
    Repo.all(Bookmark)
  end
  
end
