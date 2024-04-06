defmodule Garage.Accounts.User do
  use Ash.Resource,
    domain: Garage.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  actions do
    defaults [:create, :read, :update]

    update :new_color do
      require_atomic? false
      change Garage.Changes.ResetNonce
      change Garage.Changes.SetColor
    end
  end

  changes do
    change Garage.Changes.SetNonce
    change Garage.Changes.SetColor
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :username, :string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :avatar_url, :string, public?: true

    attribute :color, :string,
      allow_nil?: false,
      generated?: true,
      always_select?: true,
      public?: true

    attribute :color_nonce, :string, allow_nil?: false, generated?: true, public?: true
    attribute :profile, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  code_interface do
    define :get_by_id, action: :read, get_by: :id
    define :get_by_username, action: :read, get_by: :username
    define :read_all, action: :read
    define :generate_new_color, action: :new_color
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
        confirmation_required? false

        register_action_accept [
          :username,
          :name,
          :color,
          :color_nonce
        ]

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
    identity :username, [:username]
  end

  relationships do
    has_many :builds, Garage.Builds.Build do
      domain Garage.Builds
      destination_attribute :builder_id
    end
  end
end
