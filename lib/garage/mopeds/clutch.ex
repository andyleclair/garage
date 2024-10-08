defmodule Garage.Mopeds.Clutch do
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

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :clutch_tunings, Garage.Builds.ClutchTuning do
      domain Garage.Builds
      public? true
    end

    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
      public? true
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

  defimpl GarageWeb.OptionsFormatter do
    def format(clutch) do
      "#{clutch.manufacturer.name} #{clutch.name}"
    end
  end
end
