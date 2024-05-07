defmodule GarageWeb.Options do
  @spec to_options([OptionsFormatter.t()]) :: [{binary(), binary()}]
  def to_options(things) do
    for thing <- things, into: [] do
      if is_map(thing) do
        {GarageWeb.OptionsFormatter.format(thing), thing.id}
      else
        {GarageWeb.OptionsFormatter.format(thing), thing}
      end
    end
  end
end

defprotocol GarageWeb.OptionsFormatter do
  @doc "Formats a resource for inclusion in a live_select input"
  def format(resource)
end

defimpl GarageWeb.OptionsFormatter, for: Atom do
  def format(thing) do
    GarageWeb.CoreComponents.humanize(thing)
  end
end
