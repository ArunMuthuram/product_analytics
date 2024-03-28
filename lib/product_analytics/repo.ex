defmodule ProductAnalytics.Repo do
  use Ecto.Repo,
    otp_app: :product_analytics,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Changeset
  import Ecto.Query
  alias ProductAnalytics.Event

  def create_event(nil), do: {:error, "Body cannot be null"}

  def create_event(events_body) do
    events_body = set_event_time(events_body)

    changeset =
      %Event{}
      |> cast(events_body, [:user_id, :event_name, :event_time, :attributes])
      |> validate_required([:user_id, :event_name, :attributes])
      |> validate_attribute_keys

    case insert(changeset) do
      {:error, changeset} -> {:error, construct_error_message(changeset.errors)}
      result -> result
    end
  end

  defp set_event_time(events_body) do
    case DateTime.from_iso8601(events_body["event_time"] || "") do
      {:ok, _, _} ->
        events_body

      {:error, _} ->
        Map.put(events_body, "event_time", DateTime.utc_now() |> DateTime.truncate(:second))
    end
  end

  defp construct_error_message(changeset_errors) do
    blank_err_msg = construct_blank_error_message(changeset_errors)

    if blank_err_msg != "",
      do: blank_err_msg,
      else: construct_attributes_error_message(changeset_errors)
  end

  defp construct_blank_error_message(changeset_errors) do
    blank_fields =
      changeset_errors
      |> Enum.filter(fn {_, {msg, _}} -> msg == "can't be blank" end)
      |> Enum.map(fn error -> elem(error, 0) end)
      |> Enum.join(", ")

    if blank_fields == "",
      do: "",
      else: "Required fields cannot be null or empty: #{blank_fields}"
  end

  defp construct_attributes_error_message(changeset_errors) do
    case Enum.filter(changeset_errors, fn {key, _} -> key == :attributes end) |> List.first() do
      nil -> ""
      {_, {msg, _}} -> msg
    end
  end

  defp validate_attribute_keys(changeset) do
    err_msg =
      "Required field \"attribute\" must be a valid object with keys and values of type string"

    data = fetch_field(changeset, :attributes) |> elem(1)

    cond do
      !is_map(data) || map_size(data) == 0 ||
          Enum.any?(data, fn {key, val} -> !is_binary(key) || !is_binary(val) end) ->
        add_error(changeset, :attributes, err_msg)

      true ->
        changeset
    end
  end

  defp query_by_event_name(event_name) do
    query = from(e in "events")
    if event_name, do: from(e in query, where: e.event_name == ^event_name), else: query
  end

  def fetch_user_analytics(%Plug.Conn{query_params: query_params}) do
    event_name = Map.get(query_params, "event_name", nil)
    query = query_by_event_name(event_name)

    query =
      from(e in query,
        group_by: e.user_id,
        order_by: [desc: max(e.event_time)],
        select: %{
          "user_id" => e.user_id,
          "last_event_at" => max(e.event_time),
          "event_count" => count(e)
        }
      )

    ProductAnalytics.Repo.all(query)
  end

  defmacrop date_cast(date_time) do
    quote do
      fragment("DATE(?)", unquote(date_time))
    end
  end

  def fetch_event_analytics(%Plug.Conn{query_params: query_params}) do
    from = Map.get(query_params, "from", "")
    to = Map.get(query_params, "to", "")
    event_name = Map.get(query_params, "event_name", nil)

    with {:ok, {from_utc, to_utc}} <- validate_range(from, to) do
      query = query_by_event_name(event_name)

      query =
        from(e in query,
          where: e.event_time >= ^from_utc and e.event_time <= ^to_utc,
          group_by: date_cast(e.event_time),
          order_by: date_cast(e.event_time),
          select: %{
            "date" => date_cast(e.event_time),
            "count" => count(e),
            "unique_count" => count(e.user_id, :distinct)
          }
        )

      {:ok, ProductAnalytics.Repo.all(query)}
    else
      err -> err
    end
  end

  defp validate_range(from, to) do
    with {:ok, _} <- Date.from_iso8601(from),
         {:ok, from_utc, _} <- DateTime.from_iso8601("#{from}T00:00:00Z"),
         {:ok, _} <- Date.from_iso8601(to),
         {:ok, to_utc, _} <- DateTime.from_iso8601("#{to}T23:59:59Z"),
         :lt <- DateTime.compare(from_utc, to_utc) do
      {:ok, {from_utc, to_utc}}
    else
      :gt -> {:error, "To date must be greater than From date"}
      _ -> {:error, "From and to dates must be in the format yyyy-mm-dd"}
    end
  end
end
