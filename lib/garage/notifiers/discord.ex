defmodule Garage.Notifiers.Discord do
  use Ash.Notifier
  use GarageWeb, :verified_routes
  alias Nostrum.Api
  @channel 1_220_226_258_294_669_314

  def notify(%Ash.Notifier.Notification{data: data, action: %{type: :create}, actor: user}) do
    Api.create_message!(
      @channel,
      "#{user.username} just created a new build, check it out! #{data.name} https://moped.build/builds/#{data.slug}"
    )

    :ok
  end
end
