defmodule Garage.Accounts do
  use Ash.Domain

  resources do
    resource Garage.Accounts.User
    resource Garage.Accounts.Token
  end
end
