defmodule Garage.Clubs do
  use Ash.Domain,
    otp_app: :garage

  resources do
    resource Garage.Clubs.Club
  end
end
