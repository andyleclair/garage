defmodule GarageWeb.AuthLive.Reset do
  use GarageWeb, :live_view
  alias Garage.Accounts
  alias Garage.Accounts.User
  alias AshPhoenix.Form

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        <%= @cta %>
      </.header>

      <div class="mx-auto max-w-sm">
        <.simple_form
          for={@form}
          phx-change="validate"
          phx-submit="submit"
          phx-trigger-action={@trigger_action}
          action={@action}
          method="POST"
        >
          <%= if @is_request? do %>
            <.input field={@form[:email]} type="email" label="Email" required />
          <% else %>
            <.input type="hidden" field={@form[:reset_token]} value={@token} />
            <.input field={@form[:password]} type="password" label="New Password" required />
          <% end %>

          <:actions>
            <.button><%= @cta %></.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :reset_request, _params) do
    socket
    |> assign(:trigger_action, false)
    |> assign(:is_request?, true)
    |> assign(:form_id, "password-reset-request-form")
    |> assign(:cta, "Reset your password")
    |> assign(:action, ~p"/auth/user/password/reset_request")
    |> assign(
      :form,
      Form.for_action(User, :request_password_reset_with_password, api: Accounts, as: "user")
      |> to_form()
    )
  end

  defp apply_action(socket, :reset, %{"token" => token}) do
    socket
    |> assign(trigger_action: false)
    |> assign(:is_request?, false)
    |> assign(:form_id, "password-reset-form")
    |> assign(:cta, "Reset your password")
    |> assign(:action, ~p"/auth/user/password/reset")
    |> assign(:token, token)
    |> assign(
      :form,
      Form.for_action(User, :password_reset_with_password, api: Accounts, as: "user")
      |> to_form()
    )
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:errors, Form.errors(form))
      |> assign(:trigger_action, form.source.valid?)

    {:noreply, socket}
  end
end
