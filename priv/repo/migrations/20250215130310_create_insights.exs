defmodule Rlinkx.Repo.Migrations.CreateInsights do
  use Ecto.Migration

  def change do
    create table(:insights) do
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :bookmark_id, references(:bookmarks, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:insights, [:user_id])
    create index(:insights, [:bookmark_id])
  end
end
