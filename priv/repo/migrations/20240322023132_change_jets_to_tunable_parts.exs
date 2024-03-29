defmodule Garage.Repo.Migrations.ChangeJetsToTunableParts do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:carburetors) do
      # Attribute removal has been commented out to avoid data loss. See the migration generator documentation for more
      # If you uncomment this, be sure to also uncomment the corresponding attribute *addition* in the `down` migration
      remove :jets

      add :tunable_parts, {:array, :text}
    end
  end

  def down do
    alter table(:carburetors) do
      remove :tunable_parts
      # This is the `down` migration of the statement:
      #
      #     remove :jets
      #

      add :jets, {:array, :text}
    end
  end
end