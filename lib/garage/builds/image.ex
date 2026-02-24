defmodule Garage.Builds.Image do
  use Ash.Resource, otp_app: :garage, domain: Garage.Builds, data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    create :manual_create do
      accept [:original_url, :thumbnail_url, :optimized_url, :index]

      argument :build_id, :uuid do
        allow_nil? false
      end

      change set_attribute(:build_id, arg(:build_id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :original_url, :string do
      allow_nil? false
      public? true
    end

    attribute :thumbnail_url, :string do
      allow_nil? true
      public? true
    end

    attribute :optimized_url, :string do
      allow_nil? true
      public? true
    end

    attribute :index, :integer do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  preparations do
    prepare build(sort: :index)
  end

  code_interface do
    define :create, action: :manual_create
    define :update, action: :update
    define :get, action: :read, get_by: :id
  end

  relationships do
    belongs_to :build, Garage.Builds.Build do
      public? true
      allow_nil? false
    end
  end

  postgres do
    table "images"
    repo Garage.Repo

    references do
      reference :build do
        on_delete :delete
      end
    end
  end
end
