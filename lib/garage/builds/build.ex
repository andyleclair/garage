defmodule Garage.Builds.Build do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Garage.Builds,
    authorizers: [Ash.Policy.Authorizer]

  require Ecto.Query

  alias Garage.Builds.{CarbTuning, Comment, Follow, Like}

  alias Garage.Mopeds.{
    Clutch,
    Crank,
    Cylinder,
    Engine,
    Exhaust,
    Ignition,
    Manufacturer,
    Model,
    Pulley,
    Variator
  }

  alias Garage.Accounts.User

  attributes do
    uuid_primary_key :id

    # General attributes
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    attribute :year, :integer, allow_nil?: false, public?: true
    attribute :image_urls, {:array, :string}, allow_nil?: false, default: [], public?: true

    attribute :slug, :string do
      allow_nil? false
      generated? true
      always_select? true
      filterable? true
      public? true
    end

    # Build specifics
    attribute :subframe, :string, public?: true
    attribute :cdi_box, :string, public?: true
    attribute :variated?, :boolean, default: false, allow_nil?: false, public?: true
    attribute :front_sprocket, :integer, public?: true
    attribute :rear_sprocket, :integer, public?: true
    attribute :gear_ratio, :string, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :likes, Like
    has_many :comments, Comment
    has_many :follows, Follow

    belongs_to :ignition, Ignition do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :carb_tuning, CarbTuning do
      public? true
    end

    belongs_to :cylinder, Cylinder do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :exhaust, Exhaust do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :clutch, Clutch do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :crank, Crank do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :variator, Variator do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :pulley, Pulley do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :engine, Engine do
      domain Garage.Mopeds
      public? true
    end

    belongs_to :builder, User do
      domain Garage.Accounts
      public? true
    end

    # manufacturer and model correspond to the frame
    # that's the thing the vin goes on and counts as "the" bike
    belongs_to :manufacturer, Manufacturer do
      domain Garage.Mopeds
      allow_nil? false
      public? true
    end

    belongs_to :model, Model do
      domain Garage.Mopeds
      allow_nil? false
      public? true
    end
  end

  code_interface do
    define :create, action: :create
    define :all_builds, action: :all_builds
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, action: :read, get_by: :id
    define :get_by_slug, action: :read, get_by: :slug
    define :latest_builds, action: :latest
    define :recently_updated, action: :recently_updated
    define :by_manufacturer, action: :by_manufacturer, args: [:manufacturer]
    define :by_model, action: :by_model, args: [:model]
    define :like
    define :dislike
    define :follow
    define :unfollow
  end

  identities do
    identity :slug, [:slug]
  end

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      accept [:name, :description, :year, :builder_id, :manufacturer_id, :model_id, :image_urls]

      change Garage.Changes.SetSlug
      change relate_actor(:builder)
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

    read :by_manufacturer do
      argument :manufacturer, :string, allow_nil?: false
      filter expr(manufacturer.slug == ^arg(:manufacturer))
    end

    read :by_model do
      argument :model, :string, allow_nil?: false
      filter expr(model.slug == ^arg(:model))
    end

    update :like do
      accept []
      require_atomic? false

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Like.like(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :dislike do
      accept []
      require_atomic? false

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

    update :follow do
      accept []
      require_atomic? false

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Follow.follow(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :unfollow do
      accept []
      require_atomic? false

      manual fn changeset, %{actor: actor} ->
        follow =
          Ecto.Query.from(follow in Follow,
            where: follow.user_id == ^actor.id,
            where: follow.build_id == ^changeset.data.id
          )

        Garage.Repo.delete_all(follow)

        {:ok, changeset.data}
      end
    end
  end

  postgres do
    table "builds"

    repo Garage.Repo
  end

  preparations do
    prepare build(
              load: [
                :builder,
                :first_image,
                :likes,
                :manufacturer,
                :model,
                engine: [:manufacturer],
                clutch: [:manufacturer],
                exhaust: [:manufacturer],
                carb_tuning: [carburetor: [:manufacturer]],
                ignition: [:manufacturer]
              ]
            )
  end

  calculations do
    calculate :liked_by_user, :boolean, expr(exists(likes, user_id == ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? false
      end
    end

    calculate :followed_by_user, :boolean, expr(exists(follows, user_id == ^arg(:user_id))) do
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
    count :follow_count, :follows
    count :comment_count, :comments
  end
end
