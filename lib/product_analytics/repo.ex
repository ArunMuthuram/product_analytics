defmodule ProductAnalytics.Repo do
  use Ecto.Repo,
    otp_app: :product_analytics,
    adapter: Ecto.Adapters.Postgres
end
