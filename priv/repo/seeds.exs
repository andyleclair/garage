# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Garage.Repo.insert!(%Garage.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Garage.Mopeds

File.read!("priv/repo/makes_and_models.json")
|> Jason.decode!()
|> Enum.map(fn {make, models} ->
  models = for model <- models, do: %{name: model["model"]}
  %{name: make, models: models}
end)
|> Mopeds.bulk_create(Garage.Mopeds.Make, :bulk_create)
