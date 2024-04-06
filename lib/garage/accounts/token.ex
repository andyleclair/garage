defmodule Garage.Accounts.Token do
  use Ash.Resource,
    domain: Garage.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    domain Garage.Accounts
  end

  postgres do
    table "tokens"
    repo Garage.Repo
  end
end
