defmodule Garage.Builds do
  use Ash.Domain

  resources do
    resource Garage.Builds.Build
    resource Garage.Builds.Like
    resource Garage.Builds.Comment
  end
end
