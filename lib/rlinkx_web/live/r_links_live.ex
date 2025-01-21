defmodule RlinkxWeb.RLinksLive do
  use RlinkxWeb, :live_view
  
  alias Rlinkx.Remote.Bookmark 
  alias Rlinkx.Repo

  def mount(_params, _session, socket) do
    link = Bookmark |> Repo.all |> List.first

    {:ok, assign(socket, hide_link?: false, link: link)}
  end

  def handle_event("toggle-link", _params, socket) do
    {:noreply, update(socket, :hide_link?, &(!&1))}
  end
end
