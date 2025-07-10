defmodule Rlinkx.Repo.Migrations.AddOwnershipToBookmarks do
  use Ecto.Migration

  def change do
    alter table(:bookmarks) do
      add :owner_id, references(:users)
    end
  end
end
