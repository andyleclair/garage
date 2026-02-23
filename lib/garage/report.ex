defmodule Garage.Report do
  alias Nostrum.Api.Message

  @channel 1_230_003_347_592_052_776

  def report_image(url) do
    Message.create(@channel, content: "Image Reported: #{url}")
  end
end
