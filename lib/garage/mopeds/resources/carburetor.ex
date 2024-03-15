defmodule Garage.Mopeds.Carburetor do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

  actions do
    defaults [:create, :read, :update, :destroy]

    read :search do
      argument :query, :string, allow_nil?: false

      filter expr(fragment("? like '%?%'", :name, ^arg(:query)))
    end
  end

  code_interface do
    define_for Garage.Mopeds
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get_by: :id
    define :search, args: [:query], action: :search
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :description, :string, default: ""

    # Possible jets that a carburetor _may_ have
    # Jetting is set per-build in a TBD join resource
    attribute :jets, {:array, :atom} do
      default ~w(main)a
      constraints items: [one_of: ~w(main idle starter power)a]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  preparations do
    prepare build(sort: [:name], load: [:manufacturer])
  end

  relationships do
    has_many :builds, Garage.Builds.Build do
      api Garage.Builds
    end

    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
      attribute_writable? true
      allow_nil? false
    end
  end

  identities do
    identity :name, [:manufacturer_id, :name]
  end

  postgres do
    table "carburetors"

    repo Garage.Repo
  end
end
