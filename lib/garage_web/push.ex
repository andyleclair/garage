defmodule GarageWeb.Push do
  @moduledoc """
  LiveView handlers for the global push notification button
  """

  defmacro __using__(_) do
    quote do
      require Logger

      def handle_event("push-subscription", %{"subscription" => params}, socket) do
        case Garage.Accounts.User.add_push_token(socket.assigns.current_user, params) do
          {:ok, user} ->
            {:noreply,
             socket
             |> Phoenix.Component.assign(:push_tokens, user.push_tokens)
             |> Phoenix.LiveView.push_event("subscription_created", %{})}

          {:error, e} ->
            Logger.error("Failed to enable push notifications: #{inspect(e)}")

            {:noreply,
             socket |> Phoenix.LiveView.put_flash(:error, "Failed to enable push notifications")}
        end
      end
    end
  end
end
