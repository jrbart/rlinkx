defmodule Rlinkx.Repo.Migrations.AddUniqueConstraintBookmarkName do
  use Ecto.Migration

  def change do
    create unique_index(:bookmarks, :name)
  end
end
