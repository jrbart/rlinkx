defmodule RlinkxWeb.RlinkxLive.ProfileComponent do
  use RlinkxWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div>
        <h2>Profile</h2>
      </div>
      <button phx-click="close-profile">
        <.icon name="hero-x-mark" class="w-5 h-5" />
      </button>
      <div>
        <h2>{@user.username}</h2>
      </div>
    </div>
    """
  end
end
