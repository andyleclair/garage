defmodule Garage.Builds.CarbTuning do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

  alias Garage.Mopeds.Carburetor

  # Tuning depends on the carburetor, different carbs have different tunable things
  attributes do
    uuid_primary_key :id

    attribute :tuning, :map, public?: true
    attribute :needle_position, :integer, public?: true
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
