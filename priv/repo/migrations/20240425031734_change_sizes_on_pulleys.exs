defmodule Garage.Repo.Migrations.ChangeSizesOnPulleys do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:pulleys) do
      # Attribute removal has been commented out to avoid data loss. See the migration generator documentation for more
      # If you uncomment this, be sure to also uncomment the corresponding attribute *addition* in the `down` migration
      remove :size

      add :sizes, {:array, :bigint}, null: false, default: []
    end
  end

  def down do
    alter table(:pulleys) do
      remove :sizes
      # This is the `down` migration of the statement:
      #
      #     remove :size
      #

      add :size, :bigint, null: false
    end
  end
end
