defmodule RlinkxWeb.RlinkxLive.Edit do
  use RlinkxWeb, :live_view

  # alias Rlinkx.Remote.Bookmark 
  alias Rlinkx.Remote

  import RlinkxWeb.BookmarkComponents

  def mount(%{"id" => id} = _params, _session, socket) do
    link = Remote.get_link(id)

    socket =
      if Remote.following?(link, socket.assigns.current_user) do
        changeset = Remote.change_link(link)

        socket
        |> assign(page_title: "Edit Link")
        |> assign(link: link)
        |> assign_form(changeset)
      else
        socket
        |> put_flash(:error, "Please follow the bookmark to edit it")
        |> push_navigate(to: ~p"/")
      end

    {:ok, socket}
  end

  def handle_event("validate-bookmark", %{"bookmark" => new_params}, socket) do
    link =
      socket.assigns.link
      |> Remote.change_link(new_params)
      |> Map.put(:action, :validate)

    changeset = Remote.change_link(link)

    {:noreply, assign_form(socket, changeset)}
  end

  # should be "update-bookmark" ?
  def handle_event("save-bookmark", %{"bookmark" => new_params}, socket) do
    case Remote.update_link(socket.assigns.link, new_params) do
      {:ok, link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link updated successfully")
         |> push_navigate(to: ~p"/link/#{link}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("delete-bookmark", %{"bookmark" => bookmark}, socket) do
    # why are we fetching link here?  It should be in the socket...
    link = Remote.get_link(bookmark)

    if Remote.list_all_insights(link) == [] do
      Remote.delete_link(link.id, socket.assigns.current_user)

      {:noreply,
       socket
       |> put_flash(:info, "Link DELETED!")
       |> push_navigate(to: ~p"/links")}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Cannot delete Bookmark that has Insights")}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end
end
