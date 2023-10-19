defmodule Garage.Repo.Migrations.AddNameToUser do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :name, :text, null: false
    end
  end

  def down do
    alter table(:users) do
      remove :name
    end
  end
end