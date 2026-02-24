defmodule Garage.DiscordConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api.Message

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!ping" ->
        Message.create(msg.channel_id, "pyongyang!")

      _ ->
        :ignore
    end
  end

  # Ignore any other events
  def handle_event(_) do
    :ok
  end
end
