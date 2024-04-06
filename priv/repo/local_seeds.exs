:erlang.system_flag(:backtrace_depth, 100)
alias AshAuthentication.Info
alias AshAuthentication.Strategy
alias Garage.Mopeds.Manufacturer
alias Garage.Mopeds.Model

strategy = Info.strategy!(Garage.Accounts.User, :password)

{:ok, _admin} =
  Strategy.action(strategy, :register, %{
    "username" => "admin",
    "name" => "admin",
    "email" => "admin@moped.build",
    "password" => "admin12345"
  })

{:ok, beavis} =
  Strategy.action(strategy, :register, %{
    "username" => "beavis",
    "name" => "Beavis",
    "email" => "beavis@moped.build",
    "password" => "beavis12345"
  })

{:ok, butthead} =
  Strategy.action(strategy, :register, %{
    "username" => "butthead",
    "name" => "Butthead",
    "email" => "butthead@moped.build",
    "password" => "butthead12345"
  })

possible_mopeds = [
  {"tomos", "colibri"},
  {"puch", "cobra"},
  {"vespa", "grande"},
  {"honda", "hobbit"},
  {"puch", "maxi"},
  {"derbi", "revolution"}
]

for i <- 1..25 do
  {make, model} = Enum.random(possible_mopeds)
  {:ok, make} = Manufacturer.get_by_slug(make, load: [:engines])
  {:ok, model} = Model.get_by_slug(make.id, model)

  Ash.Changeset.for_create(
    Garage.Builds.Build,
    :create,
    %{name: "My Build #{i} - beavis", manufacturer_id: make.id, model_id: model.id, year: 1989},
    actor: beavis
  )
  |> Ash.create!()
end

for i <- 1..25 do
  {make, model} = Enum.random(possible_mopeds)
  {:ok, make} = Manufacturer.get_by_slug(make, load: [:engines])
  {:ok, model} = Model.get_by_slug(make.id, model)

  Ash.Changeset.for_create(
    Garage.Builds.Build,
    :create,
    %{name: "My Build #{i} butthead", manufacturer_id: make.id, model_id: model.id, year: 1989},
    actor: butthead
  )
  |> Ash.create!()
end
