defmodule Garage.Builds.CylinderTuning do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds

  alias Garage.Mopeds.Cylinder

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

    attribute :blowdown, :string, public?: true
    # Image upload sometime maybe
    attribute :port_map_url, :string, public?: true
  end

  relationships do
    belongs_to :cylinder, Cylinder do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :build, Garage.Builds.Build do
      public? true
    end
  end

  postgres do
    table "cylinder_tunings"

    repo Garage.Repo
  end
end
