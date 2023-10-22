defmodule Garage.Mopeds.Model do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  alias Garage.Mopeds.Make

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:name, :make_id]
    end

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
    define_for Garage.Builds
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :description, :string, default: ""

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  postgres do
    table "models"

    repo Garage.Repo
  end

  relationships do
    belongs_to :make, Make do
      attribute_writable? true
    end
  end
end
