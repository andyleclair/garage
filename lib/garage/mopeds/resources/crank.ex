defmodule Garage.Mopeds.Crank do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

  alias Garage.Mopeds.Engine

  actions do
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
    define_for Garage.Mopeds
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  attributes do
    uuid_primary_key :id
    attribute :manufacturer, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :description, :string, default: ""
    # in mm
    attribute :stroke, :integer, allow_nil?: false

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :engine, Engine do
      attribute_writable? true
      allow_nil? false
    end
  end

  preparations do
    prepare build(sort: [:name])
  end

  postgres do
    table "cranks"

    repo Garage.Repo
  end
end
