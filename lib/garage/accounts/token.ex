defmodule Garage.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api Garage.Accounts
  end

  postgres do
    table "tokens"
    repo Garage.Repo
  end
end
