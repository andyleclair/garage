defmodule Garage.Mopeds.Carburetor do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  import Ash.Sort, only: [expr_sort: 2]

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]
  end

  code_interface do
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get_by: :id
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, default: "", public?: true
    attribute :sizes, {:array, :string}, default: [], public?: true

    # Possible tunable parts that a carburetor _may_ have
    # Jetting, atomizer, etc. is set per-build in a TBD join resource
    attribute :tunable_parts, {:array, :atom} do
      default [:main_jet]
      public? true

      constraints items: [
                    one_of: [
                      :main_jet,
                      :idle_jet,
                      :starter_jet,
                      :power_jet,
                      :needle_jet,
                      :slide,
                      :needle,
                      :atomizer
                    ]
                  ]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  preparations do
    prepare build(sort: [expr_sort(manufacturer.name, :string), :name], load: [:manufacturer])
  end

  relationships do
    has_many :carb_tunings, Garage.Builds.CarbTuning do
      domain Garage.Builds
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
