defmodule RlinkxWeb.RLinksLive do
  use RlinkxWeb, :live_view
  
  alias Rlinkx.Remote.Bookmark 
  alias Rlinkx.Repo

  def mount(_params, _session, socket) do
    links = Bookmark |> Repo.all
    link = links |> List.first

    {:ok, assign(socket, hide_link?: false, link: link, links: links)}
  end

  def handle_event("toggle-link", _params, socket) do
    {:noreply, update(socket, :hide_link?, &(!&1))}
  end

  attr :link, Bookmark, required: true

  defp bookmark_link(assigns) do
    ~H"""
      <div>
        <a href="#"> {@link.name} </a>
      </div>
    """
  end
end
