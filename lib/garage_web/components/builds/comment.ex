defmodule GarageWeb.Components.Builds.Comment do
  use GarageWeb, :component

  attr :comment, :any, doc: "the comment"

  def comment(assigns) do
    ~H"""
    <div class="rounded-md border p-4 mb-5">
      <p>"<%= @comment.text %>"</p>
      <p class="mt-2">
        - <.username user={@comment.user} />, <%= humanize_relative(@comment.inserted_at) %>
      </p>
    </div>
    """
  end
end
