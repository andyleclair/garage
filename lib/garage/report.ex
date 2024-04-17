defmodule Garage.Report do
  alias Nostrum.Api

  @channel 1_230_003_347_592_052_776

  def report_image(url) do
    Api.create_message!(@channel, "Image Reported: #{url}")
  end
end
