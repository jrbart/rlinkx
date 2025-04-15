defmodule RlinkxWeb.RlinkxLive.Index do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote

  def mount(_params, _session, socket) do
    links = Remote.get_links_and_following(socket.assigns.current_user)

    socket =
      socket
      |> assign(page_title: "All Bookmarks")
      |> stream_configure(:links, dom_id: fn {link, _} -> "links-#{link.id}" end)
      |> stream(:links, links)

    {:ok, socket}
  end
end
