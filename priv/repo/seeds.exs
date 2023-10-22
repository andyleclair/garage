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
alias Garage.Mopeds.Make
alias Garage.Mopeds.Model
alias Ash.Changeset

File.read!("priv/repo/makes_and_models.json")
|> Jason.decode!()
|> Enum.each(fn {make, models} ->
  make =
    Make
    |> Changeset.for_create(:create, name: make)
    |> Garage.Mopeds.create!()

  for model <- models do
    Model
    |> Changeset.for_create(:create, name: model["model"], make_id: make.id)
    |> Garage.Mopeds.create!()
  end
end)
