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
      socket
      |> assign(
        link: link,
        page_title: link && link.name
      )
      |> stream(:insights, insights, reset: true)
      |> assign_insight_form(Remote.changeset_link(%Insight{}))}
  end

  def assign_insight_form(socket, changeset) do
    assign(socket, :new_insight_form, to_form(changeset))
  end

  def handle_event("toggle-link", _params, socket) do
    {:noreply, update(socket, :hide_link?, &(!&1))}
  end

  def handle_event("validate-insight", %{"insight" => insight_params}, socket) do
    changeset = Remote.changeset_link(%Insight{}, insight_params)
    {:noreply, assign_insight_form(socket, changeset)}
  end

  def handle_event("submit-insight", %{"insight" => insight_params}, socket) do
    %{current_user: current_user, link: link} = socket.assigns

    socket = case Remote.create_link(link, current_user, insight_params) do
      {:ok, insight} ->
        socket
        # |> update(:insights, &(&1 ++ [insight]))
        |> stream_insert(:insights, insight)
        |> assign_insight_form(Remote.changeset_link(%Insight{}))
      {:error, changeset} ->
        assign_insight_form(socket, changeset)
    end

    {:noreply, socket}
  end

  attr :link, Bookmark, required: true

  defp bookmark_link(assigns) do
    ~H"""
      <div>
        <.link patch={~p"/link/#{@link}"}> {@link.name} </.link>
      </div>
    """
  end

  attr :dom_id, :string, required: true
  attr :insight, Insight, required: true

  defp insight(assigns) do
    ~H"""
    <div id={@dom_id}>
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
