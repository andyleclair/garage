defmodule Garage.Notifiers.Discord do
  use Ash.Notifier
  use GarageWeb, :verified_routes

  alias Nostrum.Api
  alias Ash.Notifier.Notification
  alias Garage.Builds.Build
  alias Garage.Builds.Comment
  alias Garage.Builds.Like
  @channel 1_237_258_590_675_402_794

  # def notify(n) do
  #  dbg(n)

  #  :ok
  # end

  def notify(%Notification{resource: Build, data: data, action: %{type: :create}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just created #{data.name}, check it out!  https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{name: :like}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just liked #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{name: :unlike}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just unliked #{data.name}. Bogus!  https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{name: :update}, actor: user} = n) do
    dbg(n)

    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just updated #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{name: :delete}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just deleted their build, RIP #{data.name}"
      )
    end

    :ok
  end

  def notify(
        %Notification{resource: Comment, data: data, action: %{name: :create}, actor: user} = n
      ) do
    if enabled?() do
      dbg(n)

      Api.create_message!(
        @channel,
        "#{user.username} just commented on #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  defp enabled? do
    Application.get_env(:garage, :env) == :dev
  end
end
