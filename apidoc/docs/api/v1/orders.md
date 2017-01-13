# Spree::Orders
Creating SolidusSubscriptions::LineItems though the Solidus API. The subscriptions
extension overrides the solidus orders api endpoint to accept nested attributes
for SolidusSubscriptions::LineItems.

## PATCH `/api/orders/:id`
*Authentication Required*: An api or order token must be provided

Add a new line item to the specified order which may have an associated
subscription.

### Example params:
```js
  {
    "order_token": '1234'
    "order": {
      "line_items_attributes": [{
        // line item attributes
        "subscription_line_items_attributes": [{
          "quantity": 1,          // How many to include in the subscription orders
          "end_date": "2012/12/12", // Stop processing after this date (null for ad nauseam)
          "interval_length": 1,
          "interval_units": "month", // one of: day, week, month, year
          "subscribable_id": 1234 // What item to include in the subscription order
        }]
      }]
    }
  }
```

This endpoint accepts the default subscription_line_item_attributes (which are
configurable) except for the :subscribable_id. These atrributes are:
- `:quantity`
- `:interval`
- `:end_date`
- `:subscribable_id`
