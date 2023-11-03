defmodule GarageWeb.UsersLive.Show do
  alias Garage.Accounts.User
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Card

  def mount(%{"username" => username}, session, socket) do
    {:ok, user} = User.get_by_username(username)
    {:ok, assign(socket, :user, user)}
  end
end
