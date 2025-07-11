defmodule RlinkxWeb.UserSessionController do
  use RlinkxWeb, :controller

  alias Rlinkx.Accounts
  alias RlinkxWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    params = put_in(params, ["user", "email_or_username"], params["user"]["email"])
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email_or_username" => login, "password" => password} = user_params

    if user = Accounts.get_authenticated_user(login, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the credentials are registered.
      conn
      |> put_flash(:error, "Invalid login credentials")
      |> put_flash(:login, String.slice(login, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
