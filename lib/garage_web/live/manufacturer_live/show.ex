defmodule GarageWeb.ManufacturerLive.Show do
  use GarageWeb, :live_view

  import GarageWeb.Components.Builds.Build

  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@manufacturer.name}

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/manufacturers/#{@manufacturer}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit manufacturer</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@manufacturer.name}</:item>

      <:item title="Categories">
        <.badge :for={category <- @manufacturer.categories}>
          {category}
        </.badge>
      </:item>

      <:item title="Description">{@manufacturer.description}</:item>
    </.list>

    <div :if={@builds != []} class="mt-24 flex flex-col gap-y-10">
      <.subheading>
        Builds
      </.subheading>

      <%= for build <- @builds do %>
        <.build build={build} current_user={@current_user} />
      <% end %>
    </div>

    <.pagination
      id="pagination"
      page_number={@active_page}
      page_size={@page_limit}
      entries_length={length(@builds)}
      total_entries={@total_entries}
      total_pages={@pages}
    />

    <.back navigate={~p"/manufacturers"}>Back to manufacturers</.back>

    <.modal
      :if={@live_action == :edit}
      id="manufacturer-modal"
      show
      on_cancel={JS.patch(~p"/manufacturers/#{@manufacturer}")}
    >
      <.live_component
        module={GarageWeb.ManufacturerLive.FormComponent}
        id={@manufacturer.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        manufacturer={@manufacturer}
        patch={~p"/manufacturers/#{@manufacturer}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_offset, 0)
     |> assign(:page_limit, 30)
     |> assign(:pages, 0)
     |> assign(:active_page, 1)
     |> assign(:builds, [])
     |> assign(:total_entries, 0)
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    manufacturer =
      if socket.assigns[:manufacturer] do
        socket.assigns.manufacturer
      else
        Ash.get!(Garage.Mopeds.Manufacturer,
          slug: id,
          actor: socket.assigns.current_user
        )
      end

    active_page = page(params["page"])
    offset = page_offset(active_page, socket.assigns.page_limit)
    limit = socket.assigns.page_limit

    page =
      Garage.Builds.Build
      |> Ash.Query.filter(manufacturer_id == ^manufacturer.id)
      |> Ash.read!(
        actor: socket.assigns.current_user,
        page: [limit: limit, offset: offset, count: true]
      )

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:pages, ceil(page.count / socket.assigns.page_limit))
     |> assign(:total_entries, page.count)
     |> assign(:builds, page.results)
     |> assign(:active_page, active_page)
     |> assign(:page_offset, offset)
     |> assign(:manufacturer, manufacturer)}
  end

  defp page_title(:show), do: "Show Manufacturer"
  defp page_title(:edit), do: "Edit Manufacturer"
end
