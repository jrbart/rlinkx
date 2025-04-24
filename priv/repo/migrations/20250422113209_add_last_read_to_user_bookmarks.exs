defmodule Rlinkx.Repo.Migrations.AddLastReadToUserBookmarks do
  use Ecto.Migration

  def change do
    alter table("users_bookmarks") do
      add :last_read_at, :utc_datetime
    end

  end
end
