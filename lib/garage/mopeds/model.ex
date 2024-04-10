defmodule Garage.Mopeds.Model do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  import Ash.Sort, only: [expr_sort: 2]

  alias Garage.Mopeds.Manufacturer

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      change Garage.Changes.SetSlug
    end

    read :by_slug do
      argument :manufacturer_id, :string, allow_nil?: false
      argument :slug, :string, allow_nil?: false
      get? true
      filter expr(slug == ^arg(:slug) and manufacturer_id == ^arg(:manufacturer_id))
    end

    read :by_manufacturer_id do
      argument :manufacturer_id, :string, allow_nil?: false
      filter expr(manufacturer_id == ^arg(:manufacturer_id))
    end

    read :all_models do
      pagination do
        default_limit 30
        offset? true
      end
    end
  end

  code_interface do
    define :create_model, action: :create
    define :all_models, action: :all_models
    define :by_manufacturer_id, action: :by_manufacturer_id, args: [:manufacturer_id]
    define :get_by_slug, args: [:manufacturer_id, :slug], action: :by_slug
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, default: "", public?: true

    attribute :slug, :string do
      allow_nil? false
      generated? true
      always_select? true
      filterable? true
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :slug, [:manufacturer_id, :slug]
  end

  preparations do
    prepare build(sort: [expr_sort(manufacturer.name, :string), :name], load: [:manufacturer])
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
      domain Garage.Builds
    end

    belongs_to :stock_carburetor, Garage.Mopeds.Carburetor, attribute_writable?: true
    belongs_to :stock_clutch, Garage.Mopeds.Clutch, attribute_writable?: true
    belongs_to :stock_crank, Garage.Mopeds.Crank, attribute_writable?: true
    belongs_to :stock_cylinder, Garage.Mopeds.Cylinder, attribute_writable?: true
    belongs_to :stock_engine, Garage.Mopeds.Engine, attribute_writable?: true
    belongs_to :stock_exhaust, Garage.Mopeds.Exhaust, attribute_writable?: true
    belongs_to :stock_ignition, Garage.Mopeds.Ignition, attribute_writable?: true
    belongs_to :stock_pulley, Garage.Mopeds.Pulley, attribute_writable?: true
    belongs_to :stock_variator, Garage.Mopeds.Variator, attribute_writable?: true
  end
end
