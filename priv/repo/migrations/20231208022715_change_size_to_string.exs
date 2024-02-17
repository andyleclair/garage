defmodule Garage.Repo.Migrations.ChangeSizeToString do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:carburetors) do
      modify :size, :text, default: nil
    end
  end

  def down do
    alter table(:carburetors) do
      modify :size, :bigint, default: 12
    end
  end
end
