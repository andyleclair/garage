defmodule Garage.Mopeds.Model do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

  alias Garage.Mopeds.Make

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      change Garage.Changes.SetSlug
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

    read :by_make_id do
      argument :make_id, :uuid, allow_nil?: false
      filter expr(make_id == ^arg(:make_id))
    end
  end

  code_interface do
    define_for Garage.Mopeds
    define :create_model, action: :create
    define :all_models, action: :read
    define :by_make_id, args: [:make_id], action: :by_make_id
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
    identity :slug, [:make_id, :slug]
  end

  postgres do
    table "models"

    repo Garage.Repo
  end

  relationships do
    belongs_to :make, Make do
      attribute_writable? true
    end

    has_many :builds, Garage.Builds.Build do
      api Garage.Builds
    end
  end
end
