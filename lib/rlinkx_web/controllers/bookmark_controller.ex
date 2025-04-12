defmodule RlinkxWeb.BookmarkController do
  use RlinkxWeb, :controller

  alias Rlinkx.Remote

  def redirect_if_nil(conn, _params) do
    path =
      case Remote.get_followed_links(conn.assigns.current_user) do
        [] -> ~p"/links"
        [first | _] -> ~p"/link/#{first}"
      end

    redirect(conn, to: path)
  end
end
