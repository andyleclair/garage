defmodule GarageWeb.IgnitionLive.Show do
  use GarageWeb, :live_view

  import GarageWeb.Components.Builds.Build

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@ignition.name}

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/ignitions/#{@ignition}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit ignition</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@ignition.name}</:item>

      <:item title="Description">{@ignition.description}</:item>

      <:item title="Manufacturer">{@ignition.manufacturer.name}</:item>
    </.list>

    <div :if={@ignition.ignition_tunings != []} class="mt-24 flex flex-col gap-y-10">
      <.subheading>
        Builds with this ignition
      </.subheading>

      <%= for tuning <- @ignition.ignition_tunings do %>
        <.build build={tuning.build} current_user={@current_user} />
      <% end %>
    </div>

    <.back navigate={~p"/ignitions"}>Back to ignitions</.back>

    <.modal
      :if={@live_action == :edit}
      id="ignition-modal"
      show
      on_cancel={JS.patch(~p"/ignitions/#{@ignition}")}
    >
      <.live_component
        module={GarageWeb.IgnitionLive.FormComponent}
        id={@ignition.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        ignition={@ignition}
        patch={~p"/ignitions/#{@ignition}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :ignition,
       Ash.get!(Garage.Mopeds.Ignition, id,
         actor: socket.assigns.current_user,
         load: [ignition_tunings: [:build]]
       )
     )}
  end

  defp page_title(:show), do: "Show Ignition"
  defp page_title(:edit), do: "Edit Ignition"
end
