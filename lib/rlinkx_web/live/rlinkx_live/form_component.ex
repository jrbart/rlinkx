defmodule RlinkxWeb.RlinkxLive.FormComponent do
  use RlinkxWeb, :live_component

  alias Rlinkx.Remote
  alias Rlinkx.Remote.Bookmark

  import RlinkxWeb.BookmarkComponents

  def render(assigns) do
    ~H"""
    <div id="new-bookmark-form">
      <.bookmark_form form={@form} target={@myself} deletable?={false} />
    </div>
    """
  end

  # def mount(socket) doi: {:ok, socket}

  def update(assigns, socket) do
    changeset =
      Remote.change_link(%Bookmark{owner_id: assigns.current_user.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("validate-bookmark", %{"bookmark" => new_params}, socket) do
    changeset =
      %Bookmark{}
      |> Remote.change_link(new_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save-bookmark", %{"bookmark" => new_params}, socket) do
    case Remote.create_link(Map.put(new_params, "owner_id", socket.assigns.current_user.id)) do
      {:ok, link} ->
        Remote.follow_bookmark(link, socket.assigns.current_user)

        {:noreply,
         socket
         |> put_flash(:info, "Link created successfully")
         |> push_navigate(to: ~p"/link/#{link}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
