defmodule Garage.Repo.Migrations.Reinitialize do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :name, :text, null: false
      add :email, :citext, null: false
      add :username, :text, null: false
      add :hashed_password, :text, null: false
      add :inserted_at, :utc_datetime, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

    create table(:tokens, primary_key: false) do
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
      add :extra_data, :map
      add :purpose, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :subject, :text, null: false
      add :jti, :text, null: false, primary_key: true
    end

    create table(:models, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :name, :text, null: false
      add :description, :text, default: ""
      add :slug, :text, null: false
      add :inserted_at, :utc_datetime, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")
      add :make_id, :uuid
    end

    create table(:makes, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
    end

    alter table(:models) do
      modify :make_id,
             references(:makes,
               column: :id,
               name: "models_make_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    create unique_index(:models, [:slug], name: "models_slug_index")

    alter table(:makes) do
      add :name, :text, null: false
      add :description, :text, default: ""
      add :slug, :text, null: false
      add :inserted_at, :utc_datetime, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create unique_index(:makes, [:slug], name: "makes_slug_index")

    create table(:likes, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :inserted_at, :utc_datetime, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")

      add :user_id,
          references(:users,
            column: :id,
            name: "likes_user_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false

      add :build_id, :uuid, null: false
    end

    create table(:comments, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :text, :text, null: false
      add :inserted_at, :utc_datetime, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")

      add :user_id,
          references(:users,
            column: :id,
            name: "comments_user_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false

      add :build_id, :uuid, null: false
    end

    create table(:builds, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
    end

    alter table(:likes) do
      modify :build_id,
             references(:builds,
               column: :id,
               name: "likes_build_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    create unique_index(:likes, [:user_id, :build_id], name: "likes_unique_user_and_build_index")

    alter table(:comments) do
      modify :build_id,
             references(:builds,
               column: :id,
               name: "comments_build_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    alter table(:builds) do
      add :name, :text, null: false
      add :description, :text
      add :year, :bigint, null: false
      add :image_urls, {:array, :text}, default: []
      add :slug, :text, null: false
      add :frame, :text, default: "stock"
      add :subframe, :text
      add :inserted_at, :utc_datetime, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")

      add :builder_id,
          references(:users,
            column: :id,
            name: "builds_builder_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :make_id,
          references(:makes,
            column: :id,
            name: "builds_make_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :model_id,
          references(:models,
            column: :id,
            name: "builds_model_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:builds, [:slug], name: "builds_slug_index")
  end

  def down do
    drop_if_exists unique_index(:builds, [:slug], name: "builds_slug_index")

    drop constraint(:builds, "builds_builder_id_fkey")

    drop constraint(:builds, "builds_make_id_fkey")

    drop constraint(:builds, "builds_model_id_fkey")

    alter table(:builds) do
      remove :model_id
      remove :make_id
      remove :builder_id
      remove :updated_at
      remove :inserted_at
      remove :subframe
      remove :frame
      remove :slug
      remove :image_urls
      remove :year
      remove :description
      remove :name
    end

    drop constraint(:comments, "comments_build_id_fkey")

    alter table(:comments) do
      modify :build_id, :uuid
    end

    drop_if_exists unique_index(:likes, [:user_id, :build_id],
                     name: "likes_unique_user_and_build_index"
                   )

    drop constraint(:likes, "likes_build_id_fkey")

    alter table(:likes) do
      modify :build_id, :uuid
    end

    drop table(:builds)

    drop constraint(:comments, "comments_user_id_fkey")

    drop table(:comments)

    drop constraint(:likes, "likes_user_id_fkey")

    drop table(:likes)

    drop_if_exists unique_index(:makes, [:slug], name: "makes_slug_index")

    alter table(:makes) do
      remove :updated_at
      remove :inserted_at
      remove :slug
      remove :description
      remove :name
    end

    drop_if_exists unique_index(:models, [:slug], name: "models_slug_index")

    drop constraint(:models, "models_make_id_fkey")

    alter table(:models) do
      modify :make_id, :uuid
    end

    drop table(:makes)

    drop table(:models)

    drop table(:tokens)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end