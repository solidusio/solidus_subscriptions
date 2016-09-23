# Subscription Line Items
SolidusSubscriptions::LineItems are analogous to Spree::LineItem. They indicate
the details of a subscription prior to a purchase being made.

## PATCH `/api/v1/line_item/:id`
*Authentication Required*

Update the details of a specific SolidusSubscriptions::LineItem. e.g. From the
cart page alongside Spree::LineItems.

### Example params:
```js
{
  "id" => 1,
  "token" => "abc123", // Spree api token
  "subscription_line_item" => {
    "quantity" => 21,          // number of units in each subscription order,
    "interval" => 2592000      // Time between subscription orders (in seconds... because Ruby),
    "max_installments" => 12   // Stop processing after this many subscription orders (null for ad nauseam)
  }
}
```

This endpoint accepts the default subscription_line_item_attributes (which are
configurable) except for the :subscribable_id. These atrributes are:
- `:quantity`
- `:interval`
- `:max_installments`

### Example response:
```js
{
  "id" => 1,
  "spree_line_item_id" => 1,
  "subscription_id" => nil,
  "quantity" => 21,
  "interval" => 2592000,
  "max_installments" => 12,
  "subscribable_id" => 2,
  "created_at" => "2016-09-21T18:56:31.000Z",
  "updated_at" => "2016-09-21T18:56:31.980Z"
}
```
