defmodule Garage.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  actions do
    defaults [:create, :read, :update]

    read :read_all do
    end

    read :by_id do
      # This action has one argument :id of type :uuid
      argument :id, :uuid, allow_nil?: false
      # Tells us we expect this action to return a single result
      get? true
      # Filters the `:id` given in the argument
      # against the `id` of each element in the resource
      filter expr(id == ^arg(:id))
    end

    read :by_username do
      argument :username, :string, allow_nil?: false

      get? true
      filter expr(username == ^arg(:username))
      prepare build(load: [:builds])
    end
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

  code_interface do
    define_for Garage.Accounts
    define :get_by_id, args: [:id], action: :by_id
    define :get_by_username, args: [:username], action: :by_username
    define :read_all, action: :read_all
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
end
