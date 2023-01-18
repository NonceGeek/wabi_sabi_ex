defmodule WabiSabiEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WabiSabiExWeb.Telemetry,
      # Start the Ecto repository
      WabiSabiEx.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: WabiSabiEx.PubSub},
      # Start Finch
      {Finch, name: WabiSabiEx.Finch},
      # Start the Endpoint (http/https)
      WabiSabiExWeb.Endpoint
      # Start a worker by calling: WabiSabiEx.Worker.start_link(arg)
      # {WabiSabiEx.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WabiSabiEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WabiSabiExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
