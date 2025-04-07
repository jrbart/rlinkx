defmodule Rlinkx.Repo.Migrations.CreateUsersBookmarks do
  use Ecto.Migration

  def change do
    create table(:users_bookmarks) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :bookmark_id, references(:bookmarks, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:users_bookmarks, [:user_id])
    create index(:users_bookmarks, [:bookmark_id])
    create unique_index(:users_bookmarks, [:user_id, :bookmark_id])
  end
end
