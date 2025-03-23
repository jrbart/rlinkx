defmodule RlinkxWeb.RlinkxLive do
  use RlinkxWeb, :live_view
  
  alias Rlinkx.Accounts
  alias Rlinkx.Remote.{Bookmark,Insight} 
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote
  alias RlinkxWeb.Online

  def mount(_params, _session, socket) do
    links = Remote.get_all
    connection_params=get_connect_params(socket)
    timezone = connection_params["timezone"]
    users = Accounts.all_users()
    Online.subscribe()
    online_users = Online.list()

    # Note: track will trigger an update with presence_diff
    # so if we got the list on online users after calling track
    # the first presence would be counted twice
    if connected?(socket) do
      Online.track(self(), socket.assigns.current_user)
    end


    {:ok, assign(socket,
      hide_link?: false,
      links: links,
      users: users,
      online_users: online_users,
      timezone: timezone
    )}
  end

  def handle_params(params, _uri, socket) do
    links = socket.assigns.links
    if socket.assigns[:link], do: Remote.unsubscribe_to_link(socket.assigns.link)

    link = case Map.fetch(params, "id") do
      {:ok, id} -> Enum.find(links, &(to_string(&1.id) == id))
      
      :error -> links |> List.first
    end

    Remote.subscribe_to_link(link)
  
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
      |> assign_insight_form(Remote.changeset_insight(%Insight{}))}
  end

  def assign_insight_form(socket, changeset) do
    assign(socket, :new_insight_form, to_form(changeset))
  end

  def handle_event("toggle-link", _params, socket) do
    {:noreply, update(socket, :hide_link?, &(!&1))}
  end

  def handle_event("validate-insight", %{"insight" => insight_params}, socket) do
    changeset = Remote.changeset_insight(%Insight{}, insight_params)
    {:noreply, assign_insight_form(socket, changeset)}
  end

  def handle_event("submit-insight", %{"insight" => insight_params}, socket) do
    %{current_user: current_user, link: link} = socket.assigns

    socket = case Remote.create_insight(link, current_user, insight_params) do
      {:ok, _insight} ->
        socket
        |> assign_insight_form(Remote.changeset_insight(%Insight{}))
      {:error, changeset} ->
        assign_insight_form(socket, changeset)
    end

    {:noreply, socket}
  end

  def handle_event("delete-insight", %{"id" => id}, socket) do
      Remote.delete_insight(
        String.to_integer(id), 
        socket.assigns.current_user )
      {:noreply, socket }
  end

  def handle_info({:insight_created, insight}, socket) do
    {:noreply, stream_insert(socket, :insights, insight)}
  end

  def handle_info({:insight_deleted, insight}, socket) do
    {:noreply, stream_delete(socket, :insights, insight)}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    online_users = Online.update(socket.assigns.online_users, diff)
    {:noreply, assign(socket, online_users: online_users)}
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
  attr :current_user, User, required: true
  attr :timezone, :string, required: true
  attr :insight, Insight, required: true

  defp insight(assigns) do
    ~H"""
    <div id={@dom_id} class="group">
      <div></div>
      <div>
        <.link><span>{user_name(@insight.user)}</span></.link>
        <span :if={@timezone}>{insight_timestamp(@insight, @timezone)}</span>
        <p>{@insight.body}</p>
        <button 
          class="group-hover"
          :if={@insight.user == @current_user} 
          phx-click="delete-insight"
          phx-value-id={@insight.id} 
          data-confirm="This will be permanent"
        >
          delete
        </button>
      </div>
    </div>
    """
  end

  attr :user, :string, required: true
  attr :online, :boolean, required: false

  defp user(assigns) do
    ~H"""
    <div :if={@online}>{user_name(@user)}</div>
    """
  end

  defp user_name(user) do
    [name | _] = String.split(user.email, "@")
    name
  end

  defp online?(online_users, user) do
    Map.get(online_users, user.id, 0) > 0
  end

  defp insight_timestamp(insight, timezone) do
    insight.inserted_at 
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%T", :strftime)
  end
end
