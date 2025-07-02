defmodule GarageWeb.ClubLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Active Clubs
      <:actions>
        <.link patch={~p"/clubs/new"}>
          <.button>New Club</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="clubs"
      rows={@streams.clubs}
      row_click={fn {_id, club} -> JS.navigate(~p"/clubs/#{club.slug}") end}
    >
      <:col :let={{_id, club}} label="Name">{club.name}</:col>

      <:col :let={{_id, club}} label="City">{club.city}</:col>

      <:col :let={{_id, club}} label="State">{club.state}</:col>

      <:col :let={{_id, club}} label="Country">{club.country}</:col>

      <:col :let={{_id, club}} label="Logo url">{club.logo_url}</:col>

      <:col :let={{_id, club}} label="Icon url">{club.icon_url}</:col>

      <:action :let={{_id, club}}>
        <div class="sr-only">
          <.link navigate={~p"/clubs/#{club}"}>Show</.link>
        </div>

        <.link patch={~p"/clubs/#{club}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, club}}>
        <.link
          phx-click={JS.push("delete", value: %{id: club.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="club-modal" show on_cancel={JS.patch(~p"/clubs")}>
      <.live_component
        module={GarageWeb.ClubLive.FormComponent}
        id={(@club && @club.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        club={@club}
        patch={~p"/clubs"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:clubs, Ash.read!(Garage.Clubs.Club, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Club")
    |> assign(:club, Ash.get!(Garage.Clubs.Club, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Club")
    |> assign(:club, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Clubs")
    |> assign(:club, nil)
  end

  @impl true
  def handle_info({GarageWeb.ClubLive.FormComponent, {:saved, club}}, socket) do
    {:noreply, stream_insert(socket, :clubs, club)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    club = Ash.get!(Garage.Clubs.Club, id, actor: socket.assigns.current_user)
    Ash.destroy!(club, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :clubs, club)}
  end
end
