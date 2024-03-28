# ProductAnalytics

## Setup
- Clone the repo.
- Run `mix do deps.get, compile`
- Start a local postgres server
- Update your postgres credentials in `./config/dev.exs`
- Run `mix ecto.create`, `mix ecto.migrate`
- Start the local server using `iex -S mix`
- Access the local server at http://localhost:80

## Endpoints
## Create Event

This endpoint allows you to create a new event for a user.

**HTTP Method:** POST

**Endpoint URL:** `/events`

**Request Body:**

The request body should be a JSON object with the following fields:

* `user_id` (string): Required. The ID of the user associated with the event.
* `event_time` (string, optional): The timestamp of the event in ISO 8601 format (e.g., "2024-03-29T00:00:00Z"). If omitted, the server will use the current time.
* `event_name` (string): Required. The name of the event.
* `attributes` (object, Required): A JSON object with keys and values of type string denoting metadata for the event

**Example Request Body:**

```json
{
  "user_id": "user123",
  "event_name": "subscription_activated",
  "attributes": {
    "plan": "pro",
    "source": "website"
  }
}
```
**Example Successful Response:**

```json
201 CREATED
{
  "id": 3,
  "user_id": "user123",
  "event_name": "subscription_activated",
  "attributes": {
    "plan": "pro",
    "source": "website"
  }
}
```
**Example error Responses:**

```json
400 BAD_REQUEST
Required fields cannot be null or empty: user_id, event_name

400 BAD_REQUEST
Required field "attribute" must be a valid object with keys and values of type string
```

## Fetch Event analytics for users

This endpoint allows you to fetch event analytics such as event count grouped per user.

**HTTP Method:** GET

**Endpoint URL:** `/user_analytics`

**Request params:**

* `event_name` (string): Optional. The name of the event to fetch the analytics for. If omitted, analytics will be fetched for all events.

**Example Successful Response:**

```json
200 OK
{
  "data": [
    {
      "user_id": "user1",
      "last_event_at": "2024-02-28T12:34:56Z",
      "event_count": 1
    },
    {
      "user_id": "user2",
      "last_event_at": "2024-02-23T10:35:52Z",
      "event_count": 2
    }
  ]
}

```
Results will be sorted descending by the key "last_event_at"
## Fetch Range based aggregated counts

This endpoint allows you to fetch aggregated counts for a date range. Provides total events count per day and total number of unique users per day associated to the recorded events.

**HTTP Method:** GET

**Endpoint URL:** `/event_analytics`

**Request params:**

* `from`, `to` (string): Required. From and to dates in the format yyyy-mm-dd 
* `event_name` (string): Optional. The name of the event to fetch the analytics for. If omitted, analytics will be fetched for all events.

**Example Successful Response:**

```json
200 OK
{
  "data": [
    {
      "date": "2024-03-26",
      "count": 15,
      "unique_count": 10
    },
    {
      "date": "2024-03-27",
      "count": 23,
      "unique_count": 17
    }
  ]
}
```
**Example error Responses:**

```json
400 BAD_REQUEST
From and to dates must be in the format yyyy-mm-dd

400 BAD_REQUEST
To date must be greater than From date
```
