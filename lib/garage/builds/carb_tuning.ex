defmodule Garage.Builds.CarbTuning do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

  alias Garage.Mopeds.Carburetor

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

  # Tuning depends on the carburetor, different carbs have different tunable things
  attributes do
    uuid_primary_key :id

    attribute :tuning, :map, default: %{}, public?: true
    attribute :needle_position, :integer, public?: true
    attribute :size, :string, public?: true
  end

  relationships do
    belongs_to :carburetor, Carburetor do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :build, Garage.Builds.Build do
      public? true
    end
  end

  postgres do
    table "carb_tunings"

    repo Garage.Repo
  end
end
