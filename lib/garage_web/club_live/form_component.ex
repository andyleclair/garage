defmodule GarageWeb.ClubLive.FormComponent do
  use GarageWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Create your very own club to represent you and your friends</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="club-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:city]}
          type="text"
          label="City"
        />
        <.input field={@form[:state]} type="text" label="State" />
        <.input
          field={@form[:country]}
          type="text"
          label="Country"
        />
        <.input field={@form[:logo_url]} type="text" label="Logo url" />
        <.input
          field={@form[:icon_url]}
          type="text"
          label="Icon url"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Club</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"club" => club_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, club_params))}
  end

  def handle_event("save", %{"club" => club_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: club_params) do
      {:ok, club} ->
        notify_parent({:saved, club})

        socket =
          socket
          |> put_flash(:info, "Club #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{club: club}} = socket) do
    form =
      if club do
        AshPhoenix.Form.for_update(club, :update, as: "club", actor: socket.assigns.current_user)
      else
        AshPhoenix.Form.for_create(Garage.Clubs.Club, :create,
          as: "club",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
