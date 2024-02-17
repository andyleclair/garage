defmodule GarageWeb.AuthLive.Index do
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
        <:subtitle>
          <.link navigate={@alternative_path} class="font-semibold text-brand hover:underline">
            <%= @alternative %>
          </.link>
          <.link navigate={~p"/password-reset"} class="font-semibold text-brand hover:underline">
            Forgot your password?
          </.link>
        </:subtitle>
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
          <.input field={@form[:email]} type="email" label="Email" required />
          <%= if @is_register? do %>
            <.input field={@form[:username]} label="Username" required />
            <.input field={@form[:name]} label="Full Name" required />
          <% end %>
          <.input field={@form[:password]} type="password" label="Password" required />

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

  defp apply_action(socket, :register, _params) do
    socket
    |> assign(:trigger_action, false)
    |> assign(:is_register?, true)
    |> assign(:form_id, "sign-up-form")
    |> assign(:cta, "Register a new account")
    |> assign(:alternative_path, ~p"/sign-in")
    |> assign(:alternative, "Have an account?")
    |> assign(:action, ~p"/auth/user/password/register")
    |> assign(
      :form,
      Form.for_create(User, :register_with_password, api: Accounts, as: "user")
      |> to_form()
    )
  end

  defp apply_action(socket, :sign_in, _params) do
    socket
    |> assign(trigger_action: false)
    |> assign(:is_register?, false)
    |> assign(:form_id, "sign-in-form")
    |> assign(:cta, "Sign in to account")
    |> assign(:alternative_path, ~p"/register")
    |> assign(:alternative, "Need an account?")
    |> assign(:action, ~p"/auth/user/password/sign_in")
    |> assign(
      :form,
      Form.for_action(User, :sign_in_with_password, api: Accounts, as: "user")
      |> to_form()
    )
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params)

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
