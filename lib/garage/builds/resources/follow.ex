defmodule Garage.Builds.Follow do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

  actions do
    defaults [:read, :destroy]

    create :follow do
      upsert? true
      upsert_identity :unique_user_and_build

      argument :build_id, :uuid do
        allow_nil? false
      end

      change set_attribute(:build_id, arg(:build_id))
      change relate_actor(:user)
    end
  end

  identities do
    identity :unique_user_and_build, [:user_id, :build_id]
  end

  code_interface do
    define :follow, args: [:build_id]
  end

  postgres do
    table "follows"
    repo Garage.Repo

    references do
      reference :build do
        on_delete :delete
      end

      reference :user do
        on_delete :delete
      end
    end
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, Garage.Accounts.User do
      domain Garage.Accounts
      allow_nil? false
    end

    belongs_to :build, Garage.Builds.Build do
      domain Garage.Builds
      allow_nil? false
    end
  end
end
