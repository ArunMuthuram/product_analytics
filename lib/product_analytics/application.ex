defmodule ProductAnalytics.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProductAnalytics.Repo,
      {Bandit, plug: ProductAnalytics.Router, port: 80}
    ]

    opts = [strategy: :one_for_one, name: ProductAnalytics.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
