defmodule Garage.Mopeds.Manufacturer do
  @derive {Phoenix.Param, key: :slug}
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
      argument :forks, {:array, :map}
      argument :wheels, {:array, :map}
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
      change manage_relationship(:forks, type: :create)
      change manage_relationship(:wheels, type: :create)
      change manage_relationship(:cylinders, type: :create)
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

    read :by_slug do
      argument :slug, :string, allow_nil?: false
      get? true
      filter expr(slug == ^arg(:slug))
    end

    read :by_category do
      argument :category, :atom, allow_nil?: false
      filter expr(^arg(:category) in categories)
    end
  end

  code_interface do
    define_for Garage.Mopeds
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
    define :get_by_slug, args: [:slug], action: :by_slug
    define :by_category, args: [:category], action: :by_category
  end

  @categories ~w(carburetors clutches cranks cylinders engines exhausts forks ignitions mopeds pulleys variators wheels)a
  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false

    attribute :categories, {:array, :atom} do
      constraints items: [one_of: @categories]
    end

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
    table "manufacturers"

    repo Garage.Repo
  end

  relationships do
    has_many :builds, Garage.Builds.Build do
      api Garage.Builds
    end

    has_many :carburetors, Garage.Mopeds.Carburetor
    has_many :clutches, Garage.Mopeds.Clutch
    has_many :cranks, Garage.Mopeds.Crank
    has_many :cylinders, Garage.Mopeds.Cylinder
    has_many :engines, Garage.Mopeds.Engine
    has_many :exhausts, Garage.Mopeds.Exhaust
    has_many :forks, Garage.Mopeds.Forks
    has_many :ignitions, Garage.Mopeds.Ignition
    has_many :models, Garage.Mopeds.Model
    has_many :pulleys, Garage.Mopeds.Pulley
    has_many :variators, Garage.Mopeds.Variator
    has_many :wheels, Garage.Mopeds.Wheels
  end
end
