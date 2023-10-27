defmodule Garage.Changes.SetSlug do
  use Ash.Resource.Change
  alias Ash.Changeset

  def change(changeset, _opts, _context) do
    slug = Changeset.get_attribute(changeset, :slug)
    name = Changeset.get_attribute(changeset, :name)
    slugified = slug || Slug.slugify(name)

    cond do
      is_nil(name) or name == "" ->
        {:error, field: :name, message: "must exist"}

      slug == slugified ->
        changeset

      :else ->
        Changeset.change_attribute(changeset, :slug, slugified)
    end
  end
end