defmodule GarageWeb.Components.TagSelector do
  use GarageWeb, :live_component

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :tags, :list, required: true

  attr :on_tag_update, :any,
    required: true,
    doc: "Function to call when a tag is added or removed"

  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook="TagSelector">
      <.label><%= @label %></.label>
      <div class="flex items-center flex-col !mt-1">
        <div class="flex flex-row w-full">
          <span
            :for={tag <- @tags}
            id={"badge-dismiss-#{tag}"}
            class="inline-flex items-center px-2 py-1 me-2 text-sm font-medium text-blue-800 bg-blue-100 rounded dark:bg-blue-900 dark:text-blue-300"
          >
            <%= tag %>
            <button
              class="inline-flex items-center p-1 ms-2 text-sm text-blue-400 bg-transparent rounded-sm hover:bg-blue-200 hover:text-blue-900 dark:hover:bg-blue-800 dark:hover:text-blue-300"
              aria-label="Remove"
              data-tag={tag}
            >
              <svg
                class="w-2 h-2"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 14 14"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                />
              </svg>
              <span class="sr-only">Remove badge</span>
            </button>
          </span>
        </div>
        <div class="flex flex-row w-full justify-between">
          <input
            type="text"
            class={[
              "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
              "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
              "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
              "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5",
              "mr-2"
            ]}
            id="tag-input"
            name="tag-input"
            phx-change="edit-tag"
            phx-target={@myself}
          />
          <button id="add-tag" class="mt-2"><.icon name="hero-plus" /></button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("add-tag", %{"tag" => tag}, socket) do
    tags = socket.assigns.tags ++ [tag]
    socket.assigns.on_tag_update.(tags)

    {:noreply,
     socket
     |> assign(:tags, tags)}
  end

  @impl true
  def handle_event("remove-tag", %{"tag" => tag}, socket) do
    tags = List.delete(socket.assigns.tags, tag)
    socket.assigns.on_tag_update.(tags)

    {:noreply,
     socket
     |> assign(:tags, tags)}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}
end
