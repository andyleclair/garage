defmodule Garage.Builds.Comment do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

  actions do
    defaults [:read, :destroy]

    create :create do
      change relate_actor(:user)
    end
  end

  postgres do
    table "comments"
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
    attribute :text, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Garage.Accounts.User do
      domain Garage.Accounts
      allow_nil? false
    end

    belongs_to :build, Garage.Builds.Build do
      domain Garage.Builds
      attribute_writable? true
      allow_nil? false
    end
  end
end
