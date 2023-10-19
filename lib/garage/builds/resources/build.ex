defmodule Garage.Builds.Build do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

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

    read :latest do
      prepare build(limit: 5, sort: [inserted_at: :desc])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :make, :string do
      allow_nil? false
    end

    attribute :model, :string do
      allow_nil? false
    end

    attribute :description, :string
    attribute :frame, :string, default: "stock"
    attribute :subframe, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  code_interface do
    define_for Garage.Builds
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
    define :latest_builds, action: :latest
  end

  postgres do
    table "builds"

    repo Garage.Repo
  end
end
