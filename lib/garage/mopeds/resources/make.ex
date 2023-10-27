defmodule Garage.Mopeds.Make do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      change Garage.Changes.SetSlug
    end

    create :bulk_create do
      argument :models, {:array, :map} do
        allow_nil? false
      end

      change Garage.Changes.SetSlug
      change manage_relationship(:models, type: :create)
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
  end

  code_interface do
    define_for Garage.Mopeds
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :description, :string, default: ""

    attribute :slug, :string do
      allow_nil? false
      generated? true
      always_select? true
      filterable? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :slug, [:slug]
  end

  preparations do
    prepare build(sort: [:name])
  end

  postgres do
    table "makes"

    repo Garage.Repo
  end

  relationships do
    has_many :models, Garage.Mopeds.Model

    has_many :builds, Garage.Builds.Build do
      api Garage.Builds
    end
  end
end
