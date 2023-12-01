defmodule Garage.Mopeds.Model do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

  alias Garage.Mopeds.Manufacturer

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

    read :by_manufacturer_id do
      argument :manufacturer_id, :uuid, allow_nil?: false
      filter expr(manufacturer_id == ^arg(:manufacturer_id))
    end

    read :by_slug do
      argument :slug, :string, allow_nil?: false
      get? true
      filter expr(slug == ^arg(:slug))
    end
  end

  code_interface do
    define_for Garage.Mopeds
    define :create_model, action: :create
    define :all_models, action: :read
    define :by_manufacturer_id, args: [:manufacturer_id], action: :by_manufacturer_id
    define :get_by_slug, args: [:slug], action: :by_slug
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
    identity :slug, [:manufacturer_id, :slug]
  end

  postgres do
    table "models"

    repo Garage.Repo
  end

  relationships do
    belongs_to :manufacturer, Manufacturer do
      attribute_writable? true
    end

    has_many :builds, Garage.Builds.Build do
      api Garage.Builds
    end

    belongs_to :stock_carburetor, Garage.Mopeds.Carburetor, attribute_writable?: true
    belongs_to :stock_clutch, Garage.Mopeds.Clutch, attribute_writable?: true
    belongs_to :stock_crank, Garage.Mopeds.Crank, attribute_writable?: true
    belongs_to :stock_cylinder, Garage.Mopeds.Cylinder, attribute_writable?: true
    belongs_to :stock_engine, Garage.Mopeds.Engine, attribute_writable?: true
    belongs_to :stock_exhaust, Garage.Mopeds.Exhaust, attribute_writable?: true
    belongs_to :stock_forks, Garage.Mopeds.Forks, attribute_writable?: true
    belongs_to :stock_ignition, Garage.Mopeds.Ignition, attribute_writable?: true
    belongs_to :stock_pulley, Garage.Mopeds.Pulley, attribute_writable?: true
    belongs_to :stock_variator, Garage.Mopeds.Variator, attribute_writable?: true
    belongs_to :stock_wheels, Garage.Mopeds.Wheels, attribute_writable?: true
  end
end
