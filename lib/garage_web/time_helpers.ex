defmodule GarageWeb.TimeHelpers do
  @moduledoc false

  def humanize_relative(date_time) do
    Timex.format!(date_time, "{relative}", :relative)
  end

  def to_human_date(date_time) do
    Timex.format!(date_time, "{Mshort} {D} {YYYY}")
  end
end
