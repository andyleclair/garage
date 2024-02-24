defmodule GarageWeb.Components.Pagination do
  use GarageWeb, :component

  attr :id, :string, required: true
  attr :page_number, :integer, required: true
  attr :page_size, :integer, required: true
  attr :entries_length, :integer, required: true
  attr :total_entries, :integer, required: true
  attr :total_pages, :integer, required: true

  def pagination(assigns) do
    ~H"""
    <div id={@id}>
      <div class="grid px-4 py-3 text-sm font-semibold tracking-wide text-gray-500 uppercase border-t  sm:grid-cols-9">
        <div class="flex items-center col-span-3">
          Showing <%= calculate_totals(@page_number, @page_size, @total_entries, @entries_length) %>
        </div>

        <div class="col-span-2"></div>

        <div class="flex col-span-4 mt-2 sm:mt-auto sm:justify-end">
          <nav aria-label="Table navigation">
            <ul class="inline-flex items-center">
              <%= if @page_number > 1 do %>
                <li>
                  <a
                    class="px-3 py-1 rounded-md rounded-l-lg focus:outline-none focus:shadow-outline-purple cursor-pointer"
                    patch={"?page=#{
                      if @page_number > 1 do
                        "#{@page_number - 1}"
                      else
                        "1"
                      end
                      }"}
                    aria-label="Previous"
                  >
                    <svg aria-hidden="true" class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                      <path
                        d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                        clip-rule="evenodd"
                        fill-rule="evenodd"
                      >
                      </path>
                    </svg>
                  </a>
                </li>
              <% end %>

              <%= if @page_number > 5 do %>
                <li>
                  <span class="px-3 py-1 rounded-md focus:outline-none focus:shadow-outline-gray-500">
                    ...
                  </span>
                </li>
              <% end %>

              <li :for={page <- Enum.to_list(pagination_range(@page_number, @total_pages))}>
                <.link
                  class={
                      "px-3 py-1 rounded-md focus:outline-none focus:shadow-outline-purple #{active_class(page, @page_number)} "
                    }
                  patch={"?page=#{page}"}
                >
                  <%= page %>
                </.link>
              </li>

              <%= if (@page_number + 9) < @total_pages do %>
                <li>
                  <span class="px-3 py-1 rounded-md focus:outline-none focus:shadow-outline-purple">
                    ...
                  </span>
                </li>
              <% end %>

              <%= if @page_number < @total_pages do %>
                <li>
                  <a
                    class="px-3 py-1 rounded-md rounded-r-lg focus:outline-none focus:shadow-outline-purple cursor-pointer"
                    aria-label="Next"
                    patch={"?page=#{
                      if @page_number > 1 do
                        "#{@page_number - 1}"
                      else
                        "1"
                      end
                      }"}
                  >
                    <svg class="w-4 h-4 fill-current" aria-hidden="true" viewBox="0 0 20 20">
                      <path
                        d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                        clip-rule="evenodd"
                        fill-rule="evenodd"
                      >
                      </path>
                    </svg>
                  </a>
                </li>
              <% end %>
            </ul>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  ## Private Functions

  defp calculate_totals(page_number, page_size, total_entries, entries_length) do
    starts = (page_number - 1) * page_size + 1
    ends = (page_number - 1) * page_size + entries_length

    "#{starts}-#{ends} of #{total_entries}"
  end

  defp pagination_range(page_number, total_pages) do
    if page_number > 5 do
      last_page =
        if total_pages > page_number + 5 do
          page_number + 5
        else
          total_pages
        end

      (page_number - 4)..last_page
    else
      last_page =
        if total_pages > page_number + 9 do
          10
        else
          total_pages
        end

      1..last_page
    end
  end

  def active_class(on_page, active_page) when on_page == active_page,
    do: "text-white transition-colors duration-150 bg-gray-600 border border-r-0 border-gray-600"

  def active_class(_on_page, _active_page), do: ""
end
