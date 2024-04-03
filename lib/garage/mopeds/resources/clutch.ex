defmodule Garage.Mopeds.Clutch do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

  import Ash.Sort, only: [expr_sort: 2]

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  code_interface do
    define_for Garage.Mopeds
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get_by: :id
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :description, :string, default: ""

    create_timestamp :inserted_at
    update_timestamp :updated_at
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

  preparations do
    prepare build(sort: [expr_sort(manufacturer.name, :string), :name], load: [:manufacturer])
  end

  identities do
    identity :name, [:manufacturer_id, :name]
  end

  postgres do
    table "clutches"

    repo Garage.Repo
  end
end
