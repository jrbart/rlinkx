defmodule RlinkxWeb.RlinkxLive do
  use RlinkxWeb, :live_view
  
  alias Rlinkx.Remote.{Bookmark,Insight} 
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

    insights = if link do
      Remote.list_all_insights(link) 
    end

    {:noreply,
      assign(socket,
        link: link,
        insights: insights,
        page_title: link && link.name
    )}
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

  attr :insight, Insight, required: true

  defp insight(assigns) do
    ~H"""
    <div>
      <div></div>
      <div>
        <.link><span>{user(@insight.user)}</span></.link>
        <p>{@insight.body}</p>
      </div>
    </div>
    """
  end

  defp user(user) do
    [name | _] = String.split(user.email, "@")
    name
  end
end
