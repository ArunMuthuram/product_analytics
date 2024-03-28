defmodule ProductAnalytics.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :user_id, :string, null: false
      add :event_name, :string, null: false
      add :event_time, :utc_datetime, null: false
      add :attributes, :map, default: %{}
    end
  end
end
