defmodule GarageWeb.AuthController do
  use GarageWeb, :controller
  use AshAuthentication.Phoenix.Controller

  def success(conn, {:password, activity}, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/"
    IO.inspect(activity)

    if activity == :sign_up do
      Garage.Accounts.Emails.deliver_welcome_email(user, ~p"/#{user}")

      conn
      |> delete_session(:return_to)
      |> store_in_session(user)
      |> assign(:current_user, user)
      |> put_flash(:info, "Welcome!")
      |> redirect(to: return_to)
    else
      conn
      |> delete_session(:return_to)
      |> store_in_session(user)
      |> assign(:current_user, user)
      |> put_flash(:info, "Success!")
      |> redirect(to: return_to)
    end
  end

  def failure(conn, _activity, _reason) do
    conn
    |> put_status(401)
    |> render("failure.html")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> put_flash(:info, "Logged Out!")
    |> redirect(to: return_to)
  end
end
