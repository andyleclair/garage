defmodule Garage.Repo.Migrations.AddProfileToUser do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :profile, :text
    end
  end

  def down do
    alter table(:users) do
      remove :profile
    end
  end
end