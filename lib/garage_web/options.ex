defmodule GarageWeb.Options do
  @spec to_options([OptionsFormatter.t()]) :: [{binary(), binary()}]
  def to_options(things) do
    for thing <- things, into: [] do
      {GarageWeb.OptionsFormatter.format(thing), thing.id}
    end
  end
end

defprotocol GarageWeb.OptionsFormatter do
  @doc "Formats a resource for inclusion in a live_select input"
  def format(resource)
end
