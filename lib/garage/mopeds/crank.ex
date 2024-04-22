defmodule Garage.Mopeds.Crank do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  import Ash.Sort, only: [expr_sort: 2]
  alias Garage.Mopeds.Engine

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
    # in mm, public?: true
    attribute :stroke, :integer, public?: true
    attribute :conn_rod_length, :integer, public?: true
    attribute :small_end_bearing_diameter, :integer, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :engine, Engine do
      attribute_writable? true
    end

    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
      attribute_writable? true
      allow_nil? false
    end
  end

  preparations do
    prepare build(
              sort: [expr_sort(manufacturer.name, :string), :name],
              load: [:manufacturer, :engine]
            )
  end

  identities do
    identity :name, [:manufacturer_id, :name]
  end

  postgres do
    table "cranks"

    repo Garage.Repo
  end

  defimpl GarageWeb.OptionsFormatter do
    def format(crank) do
      "#{crank.manufacturer.name} #{crank.name}"
    end
  end
end
