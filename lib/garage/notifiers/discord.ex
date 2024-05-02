defmodule Garage.Notifiers.Discord do
  use Ash.Notifier
  use GarageWeb, :verified_routes
  alias Nostrum.Api
  @channel 1_220_226_258_294_669_314
  @env Application.compile_env(:garage, :env)

  def notify(%Ash.Notifier.Notification{data: data, action: %{type: :create}, actor: user}) do
    if @env == :prod do
      Api.create_message!(
        @channel,
        "#{user.username} just created a new build, check it out! #{data.name} https://Moped.Club/builds/#{data.slug}"
      )
    end

    :ok
  end

  def notify(%Ash.Notifier.Notification{data: data, action: %{type: :update}, actor: user}) do
    if @env == :prod do
      Api.create_message!(
        @channel,
        "#{user.username} just updated their build, check it out! #{data.name} https://Moped.Club/builds/#{data.slug}"
      )
    end

    :ok
  end
end
