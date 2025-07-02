defmodule Garage.Clubs.Membership do
  use Ash.Resource, otp_app: :garage, domain: Garage.Clubs, data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, Garage.Accounts.User do
      domain Garage.Accounts
    end

    belongs_to :club, Garage.Clubs.Club
  end

  postgres do
    table "memberships"
    repo Garage.Repo
  end
end
