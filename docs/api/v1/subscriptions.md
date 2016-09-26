# Subscriptions

## POST `/api/v1/subscriptions/:id`
*Authentication Required*

Mark a subscription as canceled, by updating its state and removing its
actionable date to prevent further processing.

### Example params

```json
{
  "id": 1
}
```

## Example response

```
HTTP/1.1 200 OK

{
  "id": 1,
  "actionable_date": null,
  "state": "canceled",
  "user_id": 1,
  "created_at": "2016-09-26T16:40:37.660Z",
  "updated_at": "2016-09-26T16:43:55.330Z"
}
```
