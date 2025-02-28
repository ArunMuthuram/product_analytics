defmodule ProductAnalytics.MixProject do
  use Mix.Project

  def project do
    [
      app: :product_analytics,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ProductAnalytics.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:bandit, "~> 1.0"},
      {:jason, "~> 1.0"}
    ]
  end
end
