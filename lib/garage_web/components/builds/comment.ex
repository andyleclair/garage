defmodule GarageWeb.Components.Builds.Comment do
  use GarageWeb, :component

  attr :comment, :any, doc: "the comment"

  def comment(assigns) do
    ~H"""
    <div>
      <p>"<%= @comment.text %>"</p>
      <p>
        - <span style={"color: #{@comment.user.color}"}><%= @comment.user.name %></span>, <%= humanize_relative(
          @comment.inserted_at
        ) %>
      </p>
    </div>
    """
  end
end
