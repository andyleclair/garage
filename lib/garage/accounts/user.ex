defmodule Garage.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication],
    authorizers: [Ash.Policy.Authorizer]

  actions do
    defaults [:create, :read, :update]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :email, :ci_string, allow_nil?: false
    attribute :username, :string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  authentication do
    api Garage.Accounts

    strategies do
      password :password do
        identity_field :email
        confirmation_required? false
        register_action_accept [:username, :name]

        resettable do
          sender Garage.Accounts.User.Senders.SendPasswordResetEmail
        end
      end

      tokens do
        enabled? true
        token_resource Garage.Accounts.Token

        signing_secret Garage.Accounts.Secrets
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

  relationships do
    has_many :builds, Garage.Builds.Build do
      api Garage.Builds
      destination_attribute :builder_id
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end
  end
end
