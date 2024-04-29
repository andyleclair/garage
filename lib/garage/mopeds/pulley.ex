defmodule Garage.Mopeds.Pulley do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  import Ash.Sort, only: [expr_sort: 2]

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      # This action has one argument :id of type :uuid
      argument :id, :uuid, allow_nil?: false
      # Tells us we expect this action to return a single result
      get? true
      # Filters the `:id` given in the argument
      # against the `id` of each element in the resource
      filter expr(id == ^arg(:id))
    end
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
    # in mm
    attribute :sizes, {:array, :integer}, default: [], public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :builds, Garage.Builds.Build do
      domain Garage.Builds
    end

    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
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
    table "pulleys"

    repo Garage.Repo
  end

  defimpl GarageWeb.OptionsFormatter do
    def format(pulley) do
      "#{pulley.manufacturer.name} #{pulley.name}"
    end
  end
end
