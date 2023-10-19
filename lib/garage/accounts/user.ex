defmodule Garage.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
  end

  authentication do
    api Garage.Accounts

    strategies do
      password :password do
        identity_field :email
      end
    end
  end

  postgres do
    table "users"
    repo Garage.Repo
  end

  identities do
    identity :unique_email, [:email]
  end
end
