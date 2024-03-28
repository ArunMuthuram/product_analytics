defmodule ProductAnalytics.Event do
  use Ecto.Schema

  schema "events" do
    field(:user_id, :string)
    field(:event_name, :string)
    field(:event_time, :utc_datetime)
    field(:attributes, :map)
  end
end

defimpl Jason.Encoder, for: [ProductAnalytics.Event] do
  def encode(struct, opts) do
    Enum.reduce(Map.from_struct(struct), %{}, fn
      {:__meta__, _}, acc -> acc
      {:event_time, v}, acc -> Map.put(acc, :event_time, to_string(v))
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    |> Jason.Encode.map(opts)
  end
end
