defmodule RlinkxWeb.RlinkxLive do
  use RlinkxWeb, :live_view
  
  alias Rlinkx.Remote.Bookmark 
  alias Rlinkx.Remote

  def mount(_params, _session, socket) do
    links = Remote.get_all

    {:ok, assign(socket, hide_link?: false, links: links)}
  end

  def handle_params(params, _uri, socket) do
    links = socket.assigns.links

    link = case Map.fetch(params, "id") do
      {:ok, id} -> Enum.find(links, &(to_string(&1.id) == id))
      
      :error -> links |> List.first
    end

    {:noreply, assign(socket, link: link, page_title: link.name)}
  end

  def handle_event("toggle-link", _params, socket) do
    {:noreply, update(socket, :hide_link?, &(!&1))}
  end

  attr :link, Bookmark, required: true

  defp bookmark_link(assigns) do
    ~H"""
      <div>
        <.link patch={~p"/link/#{@link}"}> {@link.name} </.link>
      </div>
    """
  end
end
