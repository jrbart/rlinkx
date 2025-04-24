defmodule Rlinkx.Remote.Insight do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote.Bookmark

  schema "insights" do
    field :body, :string
    belongs_to :user, User
    belongs_to :bookmark, Bookmark

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(insight, attrs) do
    insight
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
