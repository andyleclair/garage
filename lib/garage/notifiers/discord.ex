defmodule Garage.Notifiers.Discord do
  use Ash.Notifier
  use GarageWeb, :verified_routes

  alias Ash.Notifier.Notification
  alias Garage.Accounts.User
  alias Garage.Builds.Build
  alias Garage.Builds.Comment
  alias Nostrum.Api

  @channel Application.compile_env(:garage, :discord_channel)

  def notify(%Notification{resource: User, data: data, action: %{type: :create}, actor: _user}) do
    message """
    New user just signed up! #{data.username} https://moped.club/u/#{data.username}
    """
  end

  def notify(%Notification{resource: Build, data: data, action: %{type: :create}, actor: user}) do
    message """
    #{user.username} just created #{data.name}, check it out!  https://moped.club/builds/#{data.slug}
    """
  end

  def notify(%Notification{data: data, action: %{name: :like}, actor: user}) do
    message "#{user.username} just liked #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
  end

  def notify(%Notification{data: data, action: %{name: :unlike}, actor: user}) do
    message "#{user.username} just unliked #{data.name}. Bogus!  https://moped.club/builds/#{data.slug}"
  end

  def notify(%Notification{data: data, action: %{name: :update}, actor: user}) do
    message "#{user.username} just updated #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
  end

  def notify(%Notification{data: data, action: %{name: :delete}, actor: user}) do
    message "#{user.username} just deleted their build, RIP #{data.name}"
  end

  def notify(%Notification{resource: Comment, data: data, action: %{name: :create}, actor: user}) do
    message "#{user.username} just commented on #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
  end

  # Ash.Notifier is giving us a call here and we need to pattern-match
  # what we want to be notified about, but the message handling is pretty same-y
  defp message(str) do
    if enabled?() do
      Api.create_message!(@channel, str)
    end

    :ok
  end

  defp enabled? do
    Application.get_env(:garage, :env) in [:dev, :prod]
  end
end
