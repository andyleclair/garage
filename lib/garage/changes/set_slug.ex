defmodule Garage.Changes.SetSlug do
  @moduledoc """
  Change module to set the slug on a resource
  """
  use Ash.Resource.Change
  alias Ash.Changeset

  def change(changeset, _opts, _context) do
    slug = Changeset.get_attribute(changeset, :slug)
    name = Changeset.get_attribute(changeset, :name)
    slugified = Slug.slugify(name || "")

    cond do
      is_nil(name) ->
        changeset

      slug == slugified ->
        changeset

      :else ->
        Changeset.change_attribute(changeset, :slug, slugified)
    end
  end
end
