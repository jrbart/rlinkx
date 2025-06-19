defmodule Rlinkx.Repo.Migrations.AddUsernameColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # , null: false
      add :username, :citext
    end

    execute """
            UPDATE users
            SET username = CONCAT(substring(email FROM '^[^@]+'), users.id);
            """,
            ""

    alter table(:users) do
      modify :username, :citext, null: false, from: {:citext, null: true}
    end

    create unique_index(:users, :username)
  end
end
