defmodule RlinkxWeb.RlinkxLive.Index do
  use RlinkxWeb, :live_view

  alias Rlinkx.Remote

  def mount(_params, _session, socket) do
    links = Remote.get_all()

    socket =
      socket
      |> assign(page_title: "All Bookmarks")
      |> stream(:links, links)

    {:ok, socket}
  end
end
