defmodule Garage.Mopeds.Ignition do
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

  preparations do
    prepare build(sort: [expr_sort(manufacturer.name, :string), :name], load: [:manufacturer])
  end

  identities do
    identity :name, [:manufacturer_id, :name]
  end

  relationships do
    has_many :ignition_tuning, Garage.Builds.IgnitionTuning do
      domain Garage.Builds
      public? true
    end

    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
      public? true
      allow_nil? false
    end
  end

  postgres do
    table "ignitions"

    repo Garage.Repo
  end

  defimpl GarageWeb.OptionsFormatter do
    def format(ignition) do
      "#{ignition.manufacturer.name} #{ignition.name}"
    end
  end
end
