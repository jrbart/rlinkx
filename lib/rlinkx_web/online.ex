defmodule RlinkxWeb.Online do
  alias RlinkxWeb.Presence

  @topic "online_users"

  def list() do
    @topic
    |> Presence.list()
    |> Enum.into(%{}, fn {id, %{metas: metas}} 
        -> {String.to_integer(id), length(metas)} end)
  end
  
  def track(pid, user) do
    {:ok, _} = Presence.track(pid, @topic, user.id, %{})
    :ok
  end
end
