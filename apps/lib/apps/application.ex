defmodule Apps.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    import Supervisor.Spec

    children = [
      # Starts a worker by calling: Apps.Worker.start_link(arg)
      # {Apps.Worker, arg}
      worker(Apps.Server, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Apps.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
