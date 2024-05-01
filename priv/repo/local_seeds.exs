:erlang.system_flag(:backtrace_depth, 100)
alias AshAuthentication.Info
alias AshAuthentication.Strategy
alias Garage.Mopeds.Manufacturer
alias Garage.Mopeds.Model
alias Garage.Mopeds.Engine

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
  {"tomos", "colibri", "A35"},
  {"puch", "cobra", "E50"},
  {"vespa", "grande", "Piaggio"},
  {"honda", "hobbit", "PA50ii"},
  {"puch", "maxi", "ZA50"},
  {"derbi", "revolution", "Start V"}
]

image_urls = [
  "https://pub-09d9519a20aa4503bc4336772b724d1a.r2.dev/garage%2Fusers%2Fadmin%2Fbuilds%2Fbig%20long%20ass%20moped%20bike%20name%20because%20i%20fuckin%20suck%20and%20i'm%20an%20asshole%20to%20everyone%2Fuploads%2F0223da64-fac5-4c80-b758-efc47845fc2f-IMG_23441116145026.jpeg",
  "https://pub-09d9519a20aa4503bc4336772b724d1a.r2.dev/garage%2Fusers%2Fadmin%2Fbuilds%2Fbig%20long%20ass%20moped%20bike%20name%20because%20i%20fuckin%20suck%20and%20i'm%20an%20asshole%20to%20everyone%2Fuploads%2F02fd25e1-52f3-45d4-8edc-3e10bbd9062c-MVIMG_20200715_200730.jpg",
  "https://pub-09d9519a20aa4503bc4336772b724d1a.r2.dev/garage%2Fusers%2Fadmin%2Fbuilds%2Fbig%20long%20ass%20moped%20bike%20name%20because%20i%20fuckin%20suck%20and%20i'm%20an%20asshole%20to%20everyone%2Fuploads%2F045db959-4cb0-4aeb-8230-8c6dc54b2f83-IMG_20200715_200733.jpg",
  "https://pub-09d9519a20aa4503bc4336772b724d1a.r2.dev/garage%2Fusers%2Fadmin%2Fbuilds%2Fbig%20long%20ass%20moped%20bike%20name%20because%20i%20fuckin%20suck%20and%20i'm%20an%20asshole%20to%20everyone%2Fuploads%2F0475a9cc-0d41-4fdd-8b3c-a66e9534ef1c-July%2020%2C%202014%20at%200501PM.jpg",
  "https://pub-09d9519a20aa4503bc4336772b724d1a.r2.dev/garage%2Fusers%2Fadmin%2Fbuilds%2Fbig%20long%20ass%20moped%20bike%20name%20because%20i%20fuckin%20suck%20and%20i'm%20an%20asshole%20to%20everyone%2Fuploads%2F0a747def-a8fc-4cf7-b056-54930f889101-PXL_20220828_152440295.jpg"
]

for i <- 1..25 do
  {make, model, engine} = Enum.random(possible_mopeds)
  {:ok, make} = Manufacturer.get_by_slug(make, load: [:engines])
  {:ok, model} = Model.get_by_slug(make.id, model)
  {:ok, engine} = Ash.get(Engine, %{manufacturer_id: make.id, name: engine})

  Ash.Changeset.for_create(
    Garage.Builds.Build,
    :create,
    %{
      name: "My Build #{i} - beavis",
      manufacturer_id: make.id,
      model_id: model.id,
      year: 1987,
      image_urls: image_urls,
      engine_tuning: %{engine_id: engine.id}
    },
    actor: beavis
  )
  |> Ash.create!()
end

for i <- 1..25 do
  {make, model, engine} = Enum.random(possible_mopeds)
  {:ok, make} = Manufacturer.get_by_slug(make, load: [:engines])
  {:ok, model} = Model.get_by_slug(make.id, model)
  {:ok, engine} = Ash.get(Engine, %{manufacturer_id: make.id, name: engine})

  Ash.Changeset.for_create(
    Garage.Builds.Build,
    :create,
    %{
      name: "My Build #{i} butthead",
      manufacturer_id: make.id,
      model_id: model.id,
      image_urls: image_urls,
      year: 1989,
      engine_tuning: %{engine_id: engine.id}
    },
    actor: butthead
  )
  |> Ash.create!()
end
