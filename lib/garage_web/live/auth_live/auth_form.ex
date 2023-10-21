defmodule GarageWeb.AuthLive.AuthForm do
  use GarageWeb, :live_component
  use Phoenix.HTML
  alias AshPhoenix.Form

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(trigger_action: false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params) |> dbg()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:errors, Form.errors(form) |> dbg())
      |> assign(:trigger_action, form.source.valid?)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <ul class="error-messages">
        <%= if @form.errors do %>
          <%= for {k, v} <- @form.errors do %>
            <li>
              <%= humanize("#{k |> dbg()} #{v |> dbg()}") %>
            </li>
          <% end %>
        <% end %>
      </ul>

      <.simple_form
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-trigger-action={@trigger_action}
        phx-target={@myself}
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
    """
  end
end
