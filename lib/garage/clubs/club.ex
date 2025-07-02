defmodule Garage.Clubs.Club do
  use Ash.Resource, otp_app: :garage, domain: Garage.Clubs, data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :city, :string do
      public? true
      allow_nil? false
    end

    attribute :state, :string do
      public? true
      allow_nil? false
    end

    attribute :country, :string do
      public? true
      allow_nil? false
    end

    attribute :logo_url, :string do
      public? true
    end

    attribute :icon_url, :string do
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :members, Garage.Accounts.User
  end

  postgres do
    table "clubs"
    repo Garage.Repo
  end
end
