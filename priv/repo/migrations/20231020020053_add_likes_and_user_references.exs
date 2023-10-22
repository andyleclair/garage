defmodule Garage.Repo.Migrations.AddLikesAndUserReferences do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:likes, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")

      add :user_id,
          references(:users,
            column: :id,
            name: "likes_user_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false

      add :build_id,
          references(:builds,
            column: :id,
            name: "likes_build_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false
    end

    create unique_index(:likes, [:user_id, :build_id], name: "likes_unique_user_and_build_index")

    alter table(:builds) do
      add :builder_id,
          references(:users,
            column: :id,
            name: "builds_builder_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:builds, "builds_builder_id_fkey")

    alter table(:builds) do
      remove :builder_id
    end

    drop_if_exists unique_index(:likes, [:user_id, :build_id],
                     name: "likes_unique_user_and_build_index"
                   )

    drop constraint(:likes, "likes_user_id_fkey")

    drop constraint(:likes, "likes_build_id_fkey")

    drop table(:likes)
  end
end