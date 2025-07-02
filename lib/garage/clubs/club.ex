defmodule Garage.Clubs.Club do
  use Ash.Resource, otp_app: :garage, domain: Garage.Clubs, data_layer: AshPostgres.DataLayer

  code_interface do
    define :get_by_slug, action: :read, get_by: :slug
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      accept :*
      change Garage.Changes.SetSlug
    end
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

    attribute :slug, :string do
      allow_nil? false
      generated? true
      always_select? true
      filterable? true
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :members, Garage.Clubs.Membership do
      public? true
    end
  end

  identities do
    identity :slug, [:slug]
  end

  postgres do
    table "clubs"
    repo Garage.Repo
  end
end
