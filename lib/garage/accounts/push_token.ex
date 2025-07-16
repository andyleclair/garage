defmodule Garage.Accounts.PushToken do
  use Ash.Resource, otp_app: :garage, domain: Garage.Accounts, data_layer: AshPostgres.DataLayer

  @derive {Jason.Encoder, only: [:endpoint, :keys]}
  actions do
    defaults [
      :read,
      :destroy,
      create: [:endpoint, :expiration_time, :keys],
      update: [:endpoint, :expiration_time, :keys]
    ]
  end

  identities do
    identity :endpoint, [:endpoint], eager_check?: true
  end

  attributes do
    uuid_primary_key :id

    attribute :endpoint, :string do
      allow_nil? false
      public? true
    end

    attribute :expiration_time, :datetime do
      public? true
    end

    attribute :keys, :map do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Garage.Accounts.User, public?: true, attribute_writable?: true
  end

  postgres do
    table "push_tokens"
    repo Garage.Repo
  end
end
