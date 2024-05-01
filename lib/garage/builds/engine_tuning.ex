defmodule Garage.Builds.EngineTuning do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

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

    # transmission
    attribute :transmission, :atom,
      public?: true,
      constraints: [
        one_of: [
          :single_speed,
          :two_speed_manual,
          :two_speed_automatic,
          :single_variated,
          :dual_variated,
          :hand_shift,
          :foot_shift
        ]
      ]

    attribute :drive, {:array, :atom},
      public?: true,
      constraints: [
        items: [
          one_of: [
            :chain,
            :belt,
            :shaft
          ]
        ]
      ]

    attribute :front_sprocket, :integer, public?: true
    attribute :rear_sprocket, :integer, public?: true
    attribute :gear_ratio, :string, public?: true
  end

  relationships do
    belongs_to :engine, Engine do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :build, Garage.Builds.Build do
      public? true
    end
  end

  postgres do
    table "engine_tunings"

    repo Garage.Repo
  end
end
