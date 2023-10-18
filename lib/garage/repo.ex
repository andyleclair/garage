defmodule Garage.Repo do
  use AshPostgres.Repo,
    otp_app: :garage

  # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
