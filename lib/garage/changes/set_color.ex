defmodule Garage.Changes.SetColor do
  @moduledoc """
  Change module to set the color on a user by phashing the username and a nonce of random garbo

  The nonce is so users can change it (but only randomly)
  """
  use Ash.Resource.Change
  alias Ash.Changeset

  def change(changeset, _opts, _context) do
    username = Changeset.get_attribute(changeset, :username) || ""
    nonce = Changeset.get_attribute(changeset, :color_nonce)
    color = (username <> nonce) |> ColorHash.hash() |> ColorHash.hsl_to_string()

    Changeset.change_attribute(changeset, :color, color)
  end
end
