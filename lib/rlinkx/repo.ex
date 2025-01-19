defmodule Rlinkx.Repo do
  use Ecto.Repo,
    otp_app: :rlinkx,
    adapter: Ecto.Adapters.Postgres
end
