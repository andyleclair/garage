defmodule Garage.Changes.SetNonce do
  @moduledoc """
  Set a color nonce if one didn't exist before
  """
  use Ash.Resource.Change
  alias Ash.Changeset

  @impl true
  def change(changeset, _opts, _context) do
    nonce = Changeset.get_attribute(changeset, :color_nonce)

    if is_nil(nonce) do
      Changeset.change_attribute(
        changeset,
        :color_nonce,
        Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
      )
    else
      changeset
    end
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end
end
