defmodule GarageWeb.Components.Builds.Comment do
  use GarageWeb, :component

  attr :comment, :any, doc: "the comment"

  def comment(assigns) do
    ~H"""
    <p>By: <%= @comment.user.name %></p>
    <p><%= @comment.text %></p>
    <p><%= humanize_relative(@comment.inserted_at) %></p>
    """
  end
end
