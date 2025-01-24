defmodule Garage.Changes.SetSlug do
  @moduledoc """
  Change module to set the slug on a resource
  """
  use Ash.Resource.Change
  alias Ash.Changeset

  @impl true
  def init(opts) do
    {:ok, opts}
  end

  @impl true
  def change(changeset, opts, _context) do
    slug = Changeset.get_attribute(changeset, :slug)
    name = Changeset.get_attribute(changeset, :name)
    slugified = Slug.slugify(name || "")

    cond do
      is_nil(name) ->
        changeset

      slug == slugified ->
        changeset

      :else ->
        Changeset.force_change_attribute(changeset, :slug, slugified)
    end
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  @impl true
  def batch_change(changesets, opts, context) do
    # here we could run queries or do common work required
    # for a given batch of changesets.
    # in this example, however, we just return the changesets with
    # the change logic applied.
    Enum.map(changesets, &change(&1, opts, context))
  end
end
