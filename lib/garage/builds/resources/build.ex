defmodule Garage.Builds.Build do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Builds,
    authorizers: [Ash.Policy.Authorizer]

  require Ecto.Query

  alias Garage.Builds.{Comment, Like}

  alias Garage.Mopeds.{
    Carburetor,
    Clutch,
    Crank,
    Cylinder,
    Engine,
    Exhaust,
    Forks,
    Ignition,
    Make,
    Model,
    Pulley,
    Variator,
    Wheels
  }

  alias Garage.Accounts.User

  attributes do
    uuid_primary_key :id

    # General attributes
    attribute :name, :string, allow_nil?: false
    attribute :description, :string
    attribute :year, :integer, allow_nil?: false
    attribute :image_urls, {:array, :string}, allow_nil?: false, default: []

    attribute :slug, :string do
      allow_nil? false
      generated? true
      always_select? true
      filterable? true
    end

    # Build specifics
    attribute :subframe, :string

    attribute :cdi_box, :string

    # Carburetor
    attribute :jetting, :map
    attribute :slide, :string
    attribute :needle, :string

    # Transmission
    attribute :variated?, :boolean, default: false, allow_nil?: false
    attribute :front_sprocket, :integer
    attribute :rear_sprocket, :integer
    attribute :gear_ratio, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :likes, Like
    has_many :comments, Comment

    belongs_to :Ignition, Ignition do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :carburetor, Carburetor do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :wheels, Wheels do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :forks, Forks do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :cylinder, Cylinder do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :exhaust, Exhaust do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :clutch, Clutch do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :crank, Crank do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :variator, Variator do
      api Garage.Mopeds
      attribute_writable? true
    end

    belongs_to :pulley, Pulley do
      api Garage.Mopeds
      attribute_writable? true
    end

    belongs_to :engine, Engine do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :builder, User do
      api Garage.Accounts
      attribute_writable? true
    end

    # Make and model correspond to the frame
    # that's the thing the vin goes on and counts as "the" bike
    belongs_to :make, Make do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :model, Model do
      api Garage.Mopeds
      attribute_writable? true
      allow_nil? false
    end
  end

  code_interface do
    define_for Garage.Builds
    define :create, action: :create
    define :all_builds, action: :all_builds
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
    define :get_by_slug, args: [:slug], action: :by_slug
    define :latest_builds, action: :latest
    define :recently_updated, action: :recently_updated
    define :by_make, action: :by_make, args: [:make]
    define :by_model, action: :by_model, args: [:model]
    define :like
    define :dislike
  end

  identities do
    identity :slug, [:slug]
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:name, :description, :year, :builder_id, :make_id, :model_id, :image_urls]

      change Garage.Changes.SetSlug
      change relate_actor(:builder)
    end

    read :by_id do
      # This action has one argument :id of type :uuid
      argument :id, :uuid, allow_nil?: false
      # Tells us we expect this action to return a single result
      get? true
      # Filters the `:id` given in the argument
      # against the `id` of each element in the resource
      filter expr(id == ^arg(:id))
    end

    read :by_slug do
      argument :slug, :string, allow_nil?: false
      get? true
      filter expr(slug == ^arg(:slug))
    end

    read :all_builds do
      pagination do
        default_limit 50
        offset? true
      end
    end

    read :latest do
      prepare build(limit: 5, sort: [inserted_at: :desc])
    end

    read :recently_updated do
      prepare build(limit: 5, sort: [updated_at: :desc])
    end

    read :by_make do
      argument :make, :string, allow_nil?: false
      filter expr(make.slug == ^arg(:make))
    end

    read :by_model do
      argument :model, :string, allow_nil?: false
      filter expr(model.slug == ^arg(:model))
    end

    update :like do
      accept []

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Like.like(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :dislike do
      accept []

      manual fn changeset, %{actor: actor} ->
        like =
          Ecto.Query.from(like in Like,
            where: like.user_id == ^actor.id,
            where: like.build_id == ^changeset.data.id
          )

        Garage.Repo.delete_all(like)

        {:ok, changeset.data}
      end
    end
  end

  postgres do
    table "builds"

    repo Garage.Repo
  end

  preparations do
    prepare build(load: [:builder, :make, :model, :first_image, :likes])
  end

  calculations do
    calculate :liked_by_user, :boolean, expr(exists(likes, user_id == ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? false
      end
    end

    calculate :first_image, :string, expr(at(image_urls, 0))
  end

  policies do
    policy action(:update) do
      authorize_if relates_to_actor_via(:builder)
    end

    policy always() do
      authorize_if always()
    end
  end

  aggregates do
    count :like_count, :likes
  end
end
