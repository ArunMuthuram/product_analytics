import Config

config :product_analytics, ecto_repos: [ProductAnalytics.Repo]

import_config "#{Mix.env()}.exs"
