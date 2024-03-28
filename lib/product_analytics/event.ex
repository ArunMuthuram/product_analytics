defmodule ProductAnalytics.Event do
  use Ecto.Schema

  schema "events" do
    field(:user_id, :string)
    field(:event_name, :string)
    field(:event_time, :utc_datetime)
    field(:attributes, :map)
  end
end
