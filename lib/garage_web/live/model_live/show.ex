defmodule GarageWeb.ModelLive.Show do
  import GarageWeb.Components.Builds.Build
  use GarageWeb, :live_view
  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@model.manufacturer.name} {@model.name}

      <:actions>
        <.link patch={~p"/models/#{@model}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit model</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@model.name}</:item>

      <:item title="Description">{@model.description}</:item>

      <:item title="Manufacturer">
        <.link navigate={~p"/manufacturers/#{@model.manufacturer}"}>
          {@model.manufacturer.name}
        </.link>
      </:item>

      <:item title="Stock carburetor">{@model.stock_carburetor_id}</:item>

      <:item title="Stock clutch">{@model.stock_clutch_id}</:item>

      <:item title="Stock crank">{@model.stock_crank_id}</:item>

      <:item title="Stock cylinder">{@model.stock_cylinder_id}</:item>

      <:item title="Stock engine">{@model.stock_engine_id}</:item>

      <:item title="Stock exhaust">{@model.stock_exhaust_id}</:item>

      <:item title="Stock ignition">{@model.stock_ignition_id}</:item>

      <:item title="Stock pulley">{@model.stock_pulley_id}</:item>

      <:item title="Stock variator">{@model.stock_variator_id}</:item>
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

    <.back navigate={~p"/models"}>Back to models</.back>

    <.modal
      :if={@live_action == :edit}
      id="model-modal"
      show
      on_cancel={JS.patch(~p"/models/#{@model}")}
    >
      <.live_component
        module={GarageWeb.ModelLive.FormComponent}
        id={@model.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        model={@model}
        patch={~p"/models/#{@model}"}
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
    model =
      if socket.assigns[:model] do
        socket.assigns.model
      else
        Ash.get!(Garage.Mopeds.Model, id,
          load: [:manufacturer],
          actor: socket.assigns.current_user
        )
      end

    active_page = page(params["page"])
    offset = page_offset(active_page, socket.assigns.page_limit)
    limit = socket.assigns.page_limit

    page =
      Garage.Builds.Build
      |> Ash.Query.filter(model_id == ^id)
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
     |> assign(:model, model)}
  end

  defp page_title(:show), do: "Show Model"
  defp page_title(:edit), do: "Edit Model"
end
