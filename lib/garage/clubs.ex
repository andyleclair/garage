defmodule Garage.Clubs do
  use Ash.Domain,
    otp_app: :garage

  resources do
    resource Garage.Clubs.Club
    resource Garage.Clubs.Membership
  end
end
