defmodule RlinkxWeb.RlinkxLive.FormComponent do
  use RlinkxWeb, :live_component

  alias Rlinkx.Remote
  alias Rlinkx.Remote.Bookmark

  import RlinkxWeb.BookmarkComponents

  def render(assigns) do
    ~H"""
    <div id="new-bookmark-form">
      <.bookmark_form form={@form} target={@myself}/>
    </div>
    """
  end

  def mount(socket) do
    changeset = Remote.change_link(%Bookmark{})

    { :ok, socket
      |> assign_form(changeset)
    }
  end

  # there is a default that copies assigns from the parent LiveView into the component
  # def update(assigns, socket) do
  #   {:ok, 
  #     assign(socket, assigns)
  #   }
  # end

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
    case Remote.create_link(new_params) do
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
