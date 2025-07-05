defmodule RlinkxWeb.RlinkxLive do
  use RlinkxWeb, :live_view

  alias Rlinkx.Accounts
  alias Rlinkx.Remote.{Bookmark, Insight}
  alias Rlinkx.Accounts.User
  alias Rlinkx.Remote
  alias RlinkxWeb.Online

  def mount(_params, _session, socket) do
    links = Remote.get_followed_links_with_unread_count(socket.assigns.current_user)
    connection_params = get_connect_params(socket)
    timezone = connection_params["timezone"]
    users = Accounts.all_users()
    Online.subscribe()
    online_users = Online.list()

    # We subscribe to all links so we can update the unread count whenever
    # a new insight is posted
    Enum.each(links, fn {link, _count} -> Remote.subscribe_to_link(link) end)

    # Note: track will trigger an update with presence_diff
    # so if we got the list of online users after calling track
    # the first presence would be counted twice
    if connected?(socket) do
      Online.track(self(), socket.assigns.current_user)
    end

    {:ok,
     socket
     |> assign(
       hide_link?: false,
       links: links,
       users: users,
       online_users: online_users,
       timezone: timezone,
       new_bookmark_form: to_form(Remote.change_link(%Bookmark{}))
     )
     |> stream_configure(
       :insights,
       dom_id: fn
         %Insight{id: id} -> "insight-#{id}"
         :unread_marker -> "insight-unread-marker"
         %Date{} = date -> to_string(date)
       end
     )}
  end

  def handle_params(params, _uri, socket) do
    link =
      params
      |> Map.fetch!("id")
      |> Remote.get_link!()

    last_read_at = Remote.get_last_read_at(link, socket.assigns.current_user)

    insights =
      link
      |> Remote.list_all_insights()
      |> insert_date_dividers(socket.assigns.timezone)
      |> maybe_insert_unread_marker(last_read_at)

    following? = Remote.following?(link, socket.assigns.current_user)

    if following? do
      Remote.update_last_read(link, socket.assigns.current_user)
    end

    {:noreply,
     socket
     |> assign(
       link: link,
       following?: following?,
       # link has to exist or else get_link would have raised
       page_title: link.name
     )
     |> stream(:insights, insights, reset: true)
     |> assign_insight_form(Remote.changeset_insight(%Insight{}))
     # Reset unread count for current bookmark
     |> update(:links, fn links ->
       link_id = link.id

       Enum.map(links, fn
         {%Bookmark{id: ^link_id} = link, _} -> {link, 0}
         other -> other
       end)
     end)}
  end

  def assign_insight_form(socket, changeset) do
    assign(socket, :new_insight_form, to_form(changeset))
  end

  # sort insights, shift to timezone, and insert date every time the date changes
  defp insert_date_dividers(insights, nil), do: insights

  defp insert_date_dividers(insights, timezone) do
    insights
    |> Enum.group_by(fn insight ->
      insight.inserted_at
      |> DateTime.shift_zone!(timezone)
      |> DateTime.to_date()
    end)
    |> Enum.sort_by(fn {date, _insgts} -> date end, &(Date.compare(&1, &2) != :gt))
    |> Enum.flat_map(fn {date, insights} -> [date | insights] end)
  end

  def maybe_insert_unread_marker(insights, nil), do: insights

  def maybe_insert_unread_marker(insights, last_read_at) do
    {read, unread} =
      Enum.split_while(insights, fn
        %Insight{} = insight -> DateTime.compare(insight.inserted_at, last_read_at) != :gt
        _ -> true
      end)

    if unread == [] do
      read ++ [:unread_marker]
    else
      read ++ [:unread_marker | unread]
    end
  end

  def handle_event("toggle-link", _params, socket) do
    {:noreply, update(socket, :hide_link?, &(!&1))}
  end

  def handle_event("follow-bookmark", _params, socket) do
    user = socket.assigns.current_user

    socket =
      if Remote.follow_bookmark(socket.assigns.link, user) do
        socket
        |> assign(links: Remote.get_followed_links_with_unread_count(user))
        |> assign(following?: true)
      end

    {:noreply, socket}
  end

  def handle_event("validate-insight", %{"insight" => insight_params}, socket) do
    changeset = Remote.changeset_insight(%Insight{}, insight_params)
    {:noreply, assign_insight_form(socket, changeset)}
  end

  def handle_event("submit-insight", %{"insight" => insight_params}, socket) do
    %{current_user: current_user, link: link} = socket.assigns

    socket =
      if Remote.following?(link, current_user) do
        case Remote.create_insight(link, current_user, insight_params) do
          {:ok, _insight} ->
            socket
            |> assign_insight_form(Remote.changeset_insight(%Insight{}))

          {:error, changeset} ->
            assign_insight_form(socket, changeset)
        end
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("delete-insight", %{"id" => id}, socket) do
    Remote.delete_insight(
      String.to_integer(id),
      socket.assigns.current_user
    )

    {:noreply, socket}
  end

  def handle_event("show-profile", %{"user-id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    {:noreply, assign(socket, :profile, user)}
  end

  def handle_event("close-profile", _, socket) do
    {:noreply, assign(socket, :profile, nil)}
  end

  def handle_info({:insight_created, insight}, socket) do
    link = socket.assigns.link

    socket =
      cond do
        # new insight is for currently view link (no matter who added it)
        insight.bookmark_id == link.id ->
          Remote.update_last_read(link, socket.assigns.current_user)

          socket
          |> stream_insert(:insights, insight)

        # new insight was not from current user then inc unread count
        insight.user_id != socket.assigns.current_user ->
          socket
          |> update(:links, fn links ->
            # NOTE: would this be more clear if List.keyreplace were used?
            Enum.map(links, fn
              # only update count for link that has new insight
              {%Bookmark{id: id} = link, count} when id == insight.bookmark_id ->
                # this is a naive way of updating count
                # does not take into account any deletions
                {link, count + 1}

              other ->
                other
            end)
          end)

        # Otherwise
        true ->
          socket
      end

    {:noreply, socket}
  end

  def handle_info({:insight_deleted, insight}, socket) do
    {:noreply, stream_delete(socket, :insights, insight)}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    online_users = Online.update(socket.assigns.online_users, diff)
    {:noreply, assign(socket, online_users: online_users)}
  end

  attr :link, Bookmark, required: true
  attr :unread_count, :integer, required: true

  defp bookmark_link(assigns) do
    ~H"""
    <div>
      <.link patch={~p"/link/#{@link}"}>{@link.name}</.link>
      <.unread_insight_counter count={@unread_count} />
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
        <.link phx-click="show-profile" phx-value-user-id={@insight.user.id}>
          {user_name(@insight.user)}
        </.link>
        <span :if={@timezone}>{insight_timestamp(@insight, @timezone)}</span>
        <p>{@insight.body}</p>
        <button
          :if={@insight.user == @current_user}
          class="group-hover"
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

  attr :count, :integer, required: true

  defp unread_insight_counter(assigns) do
    ~H"""
    <span :if={@count > 0}>
      {@count}
    </span>
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
    user.username
  end

  defp online?(online_users, user) do
    Map.get(online_users, user.id, 0) > 0
  end

  defp insight_timestamp(insight, timezone) do
    insight.inserted_at
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%T", :strftime)
  end

  attr :name, :string, required: true
  slot :inner_block, required: true

  defp collapsible_list(assigns) do
    ~H"""
    <div
      id={@name <> "-title"}
      phx-click={
        JS.toggle(to: "##{@name}-list")
        |> JS.toggle(to: "##{@name}-expand", display: "inline-block")
        |> JS.toggle(to: "##{@name}-collapse", display: "inline-block")
      }
    >
      <.icon name="hero-minus-micro" id={@name <> "-collapse"} style="display: inline-block" />
      <.icon name="hero-plus-micro" id={@name <> "-expand"} style="display: none" />
      {String.capitalize(@name)}
    </div>
    <div id={@name <> "-list"}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.focus_first(to: "##{id}-container")
  end
end
