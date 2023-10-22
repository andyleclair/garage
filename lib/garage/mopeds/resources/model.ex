defmodule Garage.Mopeds.Model do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

  alias Garage.Mopeds.Make

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

    read :by_make_id do
      argument :make_id, :uuid, allow_nil?: false
      filter expr(make_id == ^arg(:make_id))
    end
  end

  code_interface do
    define_for Garage.Builds
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
    define :by_make_id, args: [:make_id], action: :by_make_id
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

    has_many :builds, Garage.Builds.Build do
      api Garage.Builds
    end
  end
end
