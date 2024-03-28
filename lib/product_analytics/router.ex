defmodule ProductAnalytics.Router do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/events" do
    case ProductAnalytics.Repo.create_event(conn.body_params) do
      {:ok, event} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(event))

      {:error, err_msg} ->
        send_resp(conn, 400, err_msg)
    end
  end

  get "/user_analytics" do
    results = ProductAnalytics.Repo.fetch_user_analytics(conn)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{"data" => results}))
  end


  match _ do
    send_resp(conn, 404, "Not found")
  end
end
