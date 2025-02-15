defmodule Rlinkx.Remote.Insight do
  use Ecto.Schema
  import Ecto.Changeset

  schema "insights" do
    field :body, :string
    field :user_id, :id
    field :bookmark_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(insight, attrs) do
    insight
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
