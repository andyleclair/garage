defmodule GarageWeb.UsersLive.Show do
  alias Garage.Accounts.User
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Build

  def mount(%{"username" => username}, _session, socket) do
    case User.get_by_username(username, load: [builds: [:like_count, :follow_count]]) do
      {:ok, user} ->
        {:ok,
         socket
         |> assign(:user, user)
         |> assign(:builds, user.builds)}

      {:error, _} ->
        {:ok, socket |> put_flash(:error, "Not Found") |> redirect(to: ~p"/")}
    end
  end
end
