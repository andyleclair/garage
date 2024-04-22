defmodule Garage.Mopeds.Manufacturer do
  @derive {Phoenix.Param, key: :slug}
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      change Garage.Changes.SetSlug
    end

    create :bulk_create do
      argument :name, :string, allow_nil?: false
      argument :models, {:array, :map}
      argument :engines, {:array, :map}
      argument :carburetors, {:array, :map}
      argument :clutches, {:array, :map}
      argument :cranks, {:array, :map}
      argument :ignitions, {:array, :map}
      argument :pulleys, {:array, :map}
      argument :variators, {:array, :map}
      argument :exhausts, {:array, :map}
      argument :cylinders, {:array, :map}

      argument :categories, {:array, :atom} do
        allow_nil? false
      end

      change set_attribute(:categories, arg(:categories))
      change set_attribute(:name, arg(:name))
      change Garage.Changes.SetSlug
      change manage_relationship(:models, type: :create)
      change manage_relationship(:engines, type: :create)
      change manage_relationship(:carburetors, type: :create)
      change manage_relationship(:clutches, type: :create)
      change manage_relationship(:cranks, type: :create)
      change manage_relationship(:ignitions, type: :create)
      change manage_relationship(:pulleys, type: :create)
      change manage_relationship(:variators, type: :create)
      change manage_relationship(:exhausts, type: :create)
      change manage_relationship(:cylinders, type: :create)
    end

    read :by_category do
      argument :category, :atom, allow_nil?: false
      filter expr(^arg(:category) in categories)
    end
  end

  code_interface do
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get_by: :id
    define :get_by_slug, action: :read, get_by: :slug
    define :by_category, action: :by_category, args: [:category]
  end

  @categories ~w(carburetors clutches cranks cylinders engines exhausts ignitions mopeds pulleys variators)a
  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true

    attribute :categories, {:array, :atom} do
      constraints items: [one_of: @categories]
      public? true
    end

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
    identity :slug, [:slug]
  end

  preparations do
    prepare build(sort: [:name])
  end

  postgres do
    table "manufacturers"

    repo Garage.Repo
  end

  relationships do
    has_many :builds, Garage.Builds.Build do
      domain Garage.Builds
    end

    has_many :carburetors, Garage.Mopeds.Carburetor
    has_many :clutches, Garage.Mopeds.Clutch
    has_many :cranks, Garage.Mopeds.Crank
    has_many :cylinders, Garage.Mopeds.Cylinder
    has_many :engines, Garage.Mopeds.Engine
    has_many :exhausts, Garage.Mopeds.Exhaust
    has_many :ignitions, Garage.Mopeds.Ignition
    has_many :models, Garage.Mopeds.Model
    has_many :pulleys, Garage.Mopeds.Pulley
    has_many :variators, Garage.Mopeds.Variator
  end

  defimpl GarageWeb.OptionsFormatter do
    def format(manufacturer) do
      manufacturer.name
    end
  end
end
