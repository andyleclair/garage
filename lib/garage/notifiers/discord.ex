defmodule Garage.Notifiers.Discord do
  use Ash.Notifier
  use GarageWeb, :verified_routes

  alias Nostrum.Api
  alias Ash.Notifier.Notification
  @channel 1_220_226_258_294_669_314

  def notify(%Notification{data: data, action: %{type: :create}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just created #{data.name}, check it out!  https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{type: :update}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just updated #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{type: :delete}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just deleted their build, RIP #{data.name}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{type: :like}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just liked #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{type: :unlike}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just unliked #{data.name}. Bogus!  https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Notification{data: data, action: %{type: :comment}, actor: user}) do
    if enabled?() do
      Api.create_message!(
        @channel,
        "#{user.username} just commented on #{data.name}, check it out! https://moped.club/builds/#{data.slug}"
      )
    end

    :ok
  end

  defp enabled? do
    Application.get_env(:garage, :env) == :prod
  end
end
