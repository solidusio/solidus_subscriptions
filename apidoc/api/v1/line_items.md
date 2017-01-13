# Spree::LineItems
Creating SolidusSubscriptions::LineItems though the Solidus API. The subscriptions
extension overrides the solidus line_items api endpoint to create subscription
line items when the correct parameters are passed

## POST `/api/orders/:order_id/line_items`
*Authentication Required*: An order token must be provided
*This is a Spree API endpoint*

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
          "end_date": "2012/12/12", // When to stop processing the subscription (null for ad nauseam)
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
- `:interval_units`
- `:interval_length`
- `:end_date`
- `:subscribable_id`
