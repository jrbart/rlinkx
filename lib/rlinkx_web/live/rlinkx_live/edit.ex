defmodule RlinkxWeb.RlinkxLive.Edit do
  use RlinkxWeb, :live_view
  
  alias Rlinkx.Remote.Bookmark 
  alias Rlinkx.Remote

  def mount(%{"id" => id} = _params, _session, socket) do
    link = Remote.get_link!(id)

    changeset = Remote.change_link(link)
    IO.inspect(socket, label: "mount", limit: :infinity)

    socket =
      socket
      |> assign(page_title: "Edit Link")
      |> assign(link: link)
      |> assign_form(changeset)

    {:ok, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

end
