defmodule Garage.Mopeds.Engine do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Mopeds

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

    attribute :transmission, :atom do
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
      api Garage.Builds
    end
  end

  preparations do
    prepare build(sort: [:name])
  end

  identities do
    identity :name, [:manufacturer_id, :name]
  end

  postgres do
    table "engines"

    repo Garage.Repo
  end
end
