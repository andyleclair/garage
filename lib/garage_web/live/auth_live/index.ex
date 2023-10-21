defmodule GarageWeb.AuthLive.Index do
  use GarageWeb, :live_view

  alias Garage.Accounts
  alias Garage.Accounts.User
  alias AshPhoenix.Form

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
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= @cta %>
        <:subtitle>
          <.link navigate={@alternative_path} class="font-semibold text-brand hover:underline">
            <%= @alternative %>
          </.link>
        </:subtitle>
      </.header>

      <.live_component
        module={GarageWeb.AuthLive.AuthForm}
        id={@form_id}
        form={@form}
        is_register?={@live_action == :register}
        action={@action}
        cta={@cta}
      />
    </div>
    """
  end
end
