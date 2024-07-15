defmodule Garage.Accounts do
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Garage.Accounts.User
    resource Garage.Accounts.Token
  end
end
