defmodule ColorHash do
  @hue_range {0, 360}
  @saturation_range {50, 80}
  @lightness_range {85, 100}

  def hash(string) do
    {min_h, max_h} = @hue_range
    {min_s, max_s} = @saturation_range
    {min_l, max_l} = @lightness_range

    # Adding an extra value here just forces each value to be different.
    hue = :erlang.phash2(string <> ":h", max_h - min_h) + min_h
    saturation = :erlang.phash2(string <> ":s", max_s - min_s) + min_s
    lightness = :erlang.phash2(string <> ":l", max_l - min_l) + min_l

    {hue, saturation, lightness}
  end

  # Expected CSS format.
  def hsl_to_string({h, s, l}) do
    "hsl(#{h} #{s}% #{l}%)"
  end
end
