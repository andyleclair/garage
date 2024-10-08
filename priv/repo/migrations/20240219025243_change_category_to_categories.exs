defmodule Garage.Repo.Migrations.ChangeCategoryToCategories do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:manufacturers) do
      # Attribute removal has been commented out to avoid data loss. See the migration generator documentation for more
      # If you uncomment this, be sure to also uncomment the corresponding attribute *addition* in the `down` migration
      # remove :category

      add :categories, {:array, :text}
    end
  end

  def down do
    alter table(:manufacturers) do
      remove :categories
      # This is the `down` migration of the statement:
      #
      remove :category

      add :category, :text
    end
  end
end
