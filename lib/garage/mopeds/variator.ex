defmodule Garage.Mopeds.Variator do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Mopeds

  import Ash.Sort, only: [expr_sort: 2]

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
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, default: "", public?: true
    # in mm
    attribute :type, :atom,
      allow_nil?: false,
      default: :rollers,
      constraints: [one_of: [:rollers, :pivoting_arm]],
      public?: true

    attribute :size, :integer, public?: true
    attribute :rollers, :integer, public?: true, constraints: [min: 3, max: 8]
    attribute :roller_size, :string, public?: true, constraints: [match: ~r/^\d{2}x\d{2}$/]

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :builds, Garage.Builds.Build do
      domain Garage.Builds
    end

    belongs_to :manufacturer, Garage.Mopeds.Manufacturer do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :name, [:manufacturer_id, :name]
  end

  preparations do
    prepare build(sort: [expr_sort(manufacturer.name, :string), :name], load: [:manufacturer])
  end

  postgres do
    table "variators"

    repo Garage.Repo
  end

  defimpl GarageWeb.OptionsFormatter do
    def format(variator) do
      "#{variator.manufacturer.name} #{variator.name}"
    end
  end
end
