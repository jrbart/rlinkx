defmodule RlinkxWeb.RlinkxLive.Index do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote
  # alias Rlinkx.Remote.Bookmark
  
  # import RlinkxWeb.BookmarkComponents

  def mount(_params, _session, socket) do
    links = Remote.get_links_and_following(socket.assigns.current_user)

    socket =
      socket
      |> assign(page_title: "All Bookmarks")
      |> stream_configure(:links, dom_id: fn {link, _} -> "links-#{link.id}" end)
      |> stream(:links, links)

    {:ok, socket}
  end

  def handle_event("toggle-following", %{"id" => id}, socket) do
    {link, following?} =
      id
      |> Remote.get_link!()
      |> Remote.toggle_following_bookmark(socket.assigns.current_user)

    {:noreply, stream_insert(socket, :links, {link, following?})}
  end
end
