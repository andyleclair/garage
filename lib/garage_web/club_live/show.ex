defmodule GarageWeb.ClubLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@club.name}
      <:subtitle>This is a club record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/clubs/#{@club.slug}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit club</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@club.name}</:item>

      <:item title="City">{@club.city}</:item>

      <:item title="State">{@club.state}</:item>

      <:item title="Country">{@club.country}</:item>

      <:item title="Logo url">{@club.logo_url}</:item>

      <:item title="Icon url">{@club.icon_url}</:item>
    </.list>

    <.back navigate={~p"/clubs"}>Back to clubs</.back>

    <.modal :if={@live_action == :edit} id="club-modal" show on_cancel={JS.patch(~p"/clubs/#{@club}")}>
      <.live_component
        module={GarageWeb.ClubLive.FormComponent}
        id={@club.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        club={@club}
        patch={~p"/clubs/#{@club}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:club, Garage.Clubs.Club.get_by_slug!(slug, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Club"
  defp page_title(:edit), do: "Edit Club"
end
