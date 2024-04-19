defmodule Garage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :logger.add_handler(:my_sentry_handler, Sentry.LoggerHandler, %{
      config: %{metadata: [:file, :line]}
    })

    children = [
      GarageWeb.Telemetry,
      Garage.Repo,
      {DNSCluster, query: Application.get_env(:garage, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Garage.PubSub},

      # Start the Finch HTTP client for sending emails
      {Finch, name: Garage.Finch},
      {AshAuthentication.Supervisor, otp_app: :garage},
      {Task.Supervisor, name: Garage.TaskSupervisor},
      # Start to serve requests, typically the last entry
      GarageWeb.Endpoint
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
