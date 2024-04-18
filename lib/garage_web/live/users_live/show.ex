defmodule GarageWeb.UsersLive.Show do
  alias Garage.Accounts.User
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Build

  def mount(%{"username" => username}, _session, socket) do
    {:ok, user} = User.get_by_username(username, load: [builds: [:like_count, :follow_count]])
    {:ok, assign(socket, :user, user)}
  end
end
