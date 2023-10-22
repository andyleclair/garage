defmodule Garage.Repo.Migrations.AddMakeAndModel do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:models, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :name, :text, null: false
      add :description, :text, null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
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

    alter table(:makes) do
      add :name, :text, null: false
      add :description, :text, null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end
  end

  def down do
    alter table(:makes) do
      remove :updated_at
      remove :inserted_at
      remove :description
      remove :name
    end

    drop constraint(:models, "models_make_id_fkey")

    alter table(:models) do
      modify :make_id, :uuid
    end

    drop table(:makes)

    drop table(:models)
  end
end