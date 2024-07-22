defmodule AshDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshDemoWeb.Telemetry,
      AshDemo.Repo,
      {DNSCluster, query: Application.get_env(:ash_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AshDemo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AshDemo.Finch},
      # Start a worker by calling: AshDemo.Worker.start_link(arg)
      # {AshDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      AshDemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
