defmodule Garage.Accounts do
  use Ash.Api

  resources do
    resource Garage.Accounts.User
  end
end
