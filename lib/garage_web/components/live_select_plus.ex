defmodule GarageWeb.Components.LiveSelectPlus do
  use GarageWeb, :live_component

  attr :field, :any, doc: "the form field"
  attr :label, :string, doc: "Label for the control"
  attr :id, :string, doc: "id of the element", required: true

  attr :search_fn, :any,
    doc: "1-arity function that takes the input value and returns {:ok, results}"

  attr :debounce, :string, doc: "Debounce value"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.input field={@field} type="hidden" />
      <.simple_form for={@form} id={@id} phx-change="change" phx-debounce={@debounce}>
        <.input field={@form[:search]} />
      </.simple_form>
      <div :for={{_id, result} <- @search_results}>
        <%= result %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:form, to_form(%{"search" => ""})) |> assign(:search_results, [])}
  end

  @impl true
  def handle_event("change", %{"search" => search}, socket) do
    {:ok, results} = socket.assigns.search_fn.(search)
    {:noreply, socket |> assign(:search_results, results)}
  end
end
