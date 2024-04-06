defmodule Garage.Mopeds.Engine do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  import Ash.Sort, only: [expr_sort: 2]

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]
  end

  code_interface do
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get_by: :id
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

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
      attribute_writable? true
      allow_nil? false
    end

    has_many :builds, Garage.Builds.Build do
      domain Garage.Builds
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
end
