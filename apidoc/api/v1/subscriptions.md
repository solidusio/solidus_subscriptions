# Subscriptions

## POST `/api/v1/subscriptions/:id`
*Authentication Required*

Mark a subscription as canceled, by updating its state and removing its
actionable date to prevent further processing.

### Example params

```json
{
  "token": "userapitoken",
  "id": 1
}
```

### Example response

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

## PATCH `/api/v1/subscriptions/:id`
*Authentication Required*

Make changes to the Subscription object or the subscription line item object

### Example params

```json
{
  "token": "userapitoken",
  "id": 1,
  "line_item_attributes": {
    "quantity": 5,
    "interval_length": 1,
    "interval_units": "month"
  }
}
```

### Example response
```
HTTP/1.1 200 OK

{
  "id": 1,
  "actionable_date": nil,
  "state": "active",
  "user_id": 1,
  "created_at": "2016-09-26T23:50:32.923Z",
  "updated_at": "2016-09-26T23:50:32.923Z",
  "line_item": {
    "id": 1,
    "spree_line_item_id": 1,
    "subscription_id": 1,
    "quantity": 5,
    "end_date": "2012/12/12",
    "subscribable_id": 2,
    "created_at": "2016-09-26T23:50:32.923Z",
    "updated_at": "2016-09-26T23:51:05.784Z",
    "interval_units": "months",
    "interval_length": 1
   }
 }

```

## POST `/api/v1/subscriptions/:id/skip`
*Authentication Required*

Advance the subscription by one extra interval, thereby skipping the next
installment.

### Example params

```json
{
  "token": "userapitoken"
}
```

### Example response
```
HTTP/1.1 200 OK

{
  "id": 1,
  "actionable_date": nil,
  "state": "active",
  "user_id": 1,
  "created_at": "2016-09-26T23:50:32.923Z",
  "updated_at": "2016-09-26T23:50:32.923Z",
  "line_item": {
    "id": 1,
    "spree_line_item_id": 1,
    "subscription_id": 1,
    "quantity": 5,
    "end_date": "2012/12/12",
    "subscribable_id": 2,
    "created_at": "2016-09-26T23:50:32.923Z",
    "updated_at": "2016-09-26T23:51:05.784Z",
    "interval_units": "month",
    "interval_length": 1
   }
 }

```
