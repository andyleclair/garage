defmodule Garage.Accounts do
  use Ash.Api

  resources do
    resource Garage.Accounts.User
    resource Garage.Accounts.Token
  end
end
