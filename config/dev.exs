import Config

config :product_analytics, ProductAnalytics.Repo,
  database: "product_analytics_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
