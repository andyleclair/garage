defmodule Garage.Builds.IgnitionTuning do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

  alias Garage.Mopeds.Ignition

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

    attribute :timing, :integer, public?: true
    attribute :timing_method, :atom, public?: true, constraints: [one_of: [:degrees, :mm]]
    attribute :cdi_box, :string, public?: true
  end

  relationships do
    belongs_to :ignition, Ignition do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :build, Garage.Builds.Build do
      public? true
    end
  end

  postgres do
    table "ignition_tunings"

    repo Garage.Repo
  end
end
