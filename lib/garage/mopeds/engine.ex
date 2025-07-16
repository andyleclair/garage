defmodule Garage.Mopeds.Engine do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  import Ash.Expr
  import Ash.Sort, only: [expr_sort: 2]

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]
  end

  changes do
    change {Garage.Changes.SetSlug, parts: [expr(manufacturer.slug), :name]},
      on: [:create, :update]
  end

  code_interface do
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get_by: :id
    define :get_by_slug, action: :read, get_by: :slug
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, default: "", public?: true

    attribute :transmission, :atom do
      public? true

      constraints one_of: [
                    :single_speed,
                    :two_speed_manual,
                    :two_speed_automatic,
                    :single_variated,
                    :dual_variated,
                    :hand_shift,
                    :foot_shift
                  ]
    end

    attribute :drive, {:array, :atom} do
      public? true

      constraints items: [
                    one_of: [
                      :chain,
                      :belt,
                      :shaft
                    ]
                  ]

      default []
    end

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

  relationships do
    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
      public? true
      allow_nil? false
    end

    has_many :engine_tunings, Garage.Builds.EngineTuning do
      domain Garage.Builds
    end

    has_one :cranks, Garage.Mopeds.Crank do
      public? true
    end
  end

  preparations do
    prepare build(sort: [expr_sort(manufacturer.name, :string), :name], load: [:manufacturer])
  end

  identities do
    identity :name, [:manufacturer_id, :name]
  end

  postgres do
    table "engines"

    repo Garage.Repo
  end

  defimpl GarageWeb.OptionsFormatter do
    def format(engine) do
      "#{engine.manufacturer.name} #{engine.name}"
    end
  end
end
