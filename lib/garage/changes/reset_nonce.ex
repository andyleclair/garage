defmodule Garage.Changes.ResetNonce do
  @moduledoc """
  Change module to set the slug on a resource
  """
  use Ash.Resource.Change
  alias Ash.Changeset

  def change(changeset, _opts, _context) do
    Changeset.change_attribute(
      changeset,
      :color_nonce,
      Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
    )
  end
end
