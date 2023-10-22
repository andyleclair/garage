defmodule Garage.Builds.Like do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Builds

  actions do
    defaults [:read, :destroy]

    create :like do
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
    define_for Garage.Builds
    define :like, args: [:build_id]
  end

  postgres do
    table "likes"
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
      api Garage.Accounts
      allow_nil? false
    end

    belongs_to :build, Garage.Builds.Build do
      api Garage.Builds
      allow_nil? false
    end
  end
end
