defmodule Garage.Repo.Migrations.AddAllowedPushToUsers do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :enabled_push_notifications, :boolean, default: false
    end
  end

  def down do
    alter table(:users) do
      remove :enabled_push_notifications
    end
  end
end
