defmodule Garage.Builds.Build do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    api: Garage.Builds

  require Ecto.Query

  alias Garage.Builds.Like
  alias Garage.Mopeds.{Make, Model}
  alias Garage.Accounts.User

  actions do
    defaults [:update, :destroy]

    create :create do
      accept [:name, :description, :year, :builder_id, :make_id, :model_id]

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

    read :all_builds do
      pagination do
        default_limit 50
        offset? true
      end
    end

    read :latest do
      prepare build(limit: 5, sort: [inserted_at: :desc])
    end

    read :by_make do
      argument :make, :string, allow_nil?: false
      filter expr(make == ^arg(:make))
    end

    read :by_model do
      argument :model, :string, allow_nil?: false
      filter expr(model == ^arg(:model))
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

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :description, :string
    attribute :year, :integer, allow_nil?: false
    attribute :frame, :string, default: "stock"
    attribute :subframe, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  code_interface do
    define_for Garage.Builds
    define :create, action: :create
    define :all_builds, action: :all_builds
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
    define :latest_builds, action: :latest
    define :by_make, action: :by_make, args: [:make]
    define :by_model, action: :by_model, args: [:model]
    define :like
    define :dislike
  end

  postgres do
    table "builds"

    repo Garage.Repo
  end

  relationships do
    has_many :likes, Like

    belongs_to :builder, User do
      api Garage.Accounts
      attribute_writable? true
    end

    belongs_to :make, Make do
      api Garage.Mopeds
      attribute_writable? true
    end

    belongs_to :model, Model do
      api Garage.Mopeds
      attribute_writable? true
    end
  end

  preparations do
    prepare build(load: [:builder, :make, :model])
  end

  calculations do
    calculate :liked_by_user, :boolean, expr(exists(likes, user_id == ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? false
      end
    end
  end
end
