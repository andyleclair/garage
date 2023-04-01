defmodule Garage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GarageWeb.Telemetry,
      # Start the Ecto repository
      Garage.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Garage.PubSub},
      # Start Finch
      {Finch, name: Garage.Finch},
      # Start the Endpoint (http/https)
      GarageWeb.Endpoint
      # Start a worker by calling: Garage.Worker.start_link(arg)
      # {Garage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Garage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GarageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
