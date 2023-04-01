defmodule Garage.Repo do
  use Ecto.Repo,
    otp_app: :garage,
    adapter: Ecto.Adapters.Postgres
end
