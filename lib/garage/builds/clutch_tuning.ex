defmodule Garage.Builds.ClutchTuning do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

  alias Garage.Mopeds.Clutch

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

    attribute :springs, :string, public?: true
  end

  relationships do
    belongs_to :clutch, Clutch do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :build, Garage.Builds.Build do
      public? true
    end
  end

  postgres do
    table "clutch_tunings"

    repo Garage.Repo
  end
end
