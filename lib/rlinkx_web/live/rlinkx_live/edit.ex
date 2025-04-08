defmodule RlinkxWeb.RlinkxLive.Edit do
  use RlinkxWeb, :live_view

  # alias Rlinkx.Remote.Bookmark 
  alias Rlinkx.Remote

  def mount(%{"id" => id} = _params, _session, socket) do
    link = Remote.get_link!(id)

    changeset = Remote.change_link(link)

    socket =
      socket
      |> assign(page_title: "Edit Link")
      |> assign(link: link)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("validate-link", %{"bookmark" => new_params}, socket) do
    link =
      socket.assigns.link
      |> Remote.change_link(new_params)
      |> Map.put(:action, :validate)

    changeset = Remote.change_link(link)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save-link", %{"bookmark" => new_params}, socket) do
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end
end
