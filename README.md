# solidus_subscriptions

[![CircleCI](https://circleci.com/gh/solidusio-contrib/solidus_subscriptions.svg?style=shield)](https://circleci.com/gh/solidusio-contrib/solidus_subscriptions)
[![codecov](https://codecov.io/gh/solidusio-contrib/solidus_subscriptions/branch/master/graph/badge.svg)](https://codecov.io/gh/solidusio-contrib/solidus_subscriptions)

A Solidus extension to add subscriptions to your store.

## Installation

Add solidus_subscriptions to your Gemfile:

```ruby
gem 'solidus_subscriptions', github: 'solidusio-contrib/solidus_subscriptions'
```

Bundle your dependencies and run the installation generator:

```shell
$ bundle
$ bin/rails generate solidus_subscriptions:install
```

### Guest checkout

Subscriptions require a user to be present to allow them to be managed after they are purchased.

Because of this, you must disable guest checkout for orders which contain `subscription_line_items`.

An example would be adding this to the registration page:

```erb
<%# spree/checkout/registration.html.erb %>
<% if Spree::Config[:allow_guest_checkout] && current_order.subscription_line_items.empty? %>
```

This allows guests to add subscriptions to their carts as guests, but forces them to login or create
an account before purchasing them.

## Usage

### Purchasing subscriptions

By default, only Spree::Variants can be subscribed to. To subscribe to a variant, it must have the
`subscribable` attribute set to true.

To subscribe to a variant, include the following parameters when posting to `/orders/populate`:

```json5
{
  // other add to cart params
  subscription_line_item: {
    quantity: 2,             // number of units in each subscription order
    subscribable_id: 1234,   // which variant the subscription is for
    interval_length: 1,      // time between subscription activations
    interval_units: "month", // plural qualifier for length (day/week/month/year)
    end_date: '2011/12/13'   // stop processing after this date (use null to process ad nauseam)
  }
}
```

This will associate a `SolidusSubscriptions::LineItem` to the line item being added to the cart.

The customer will not be charged for the subscription until it is processed. The subscription line
items should be shown to the user on the cart page by looping over
`Spree::Order#subscription_line_items`.

When the order is finalized, a `SolidusSubscriptions::Subscription` will be created for each group
of subscription line items which can be fulfilled by a single subscription.

#### Example

An order is finalized and has the following associated subscription line items:

1. `{ subscribable_id: 1, interval_length: 1, interval_units: "month" }`
2. `{ subscribable_id: 2, interval_length: 1, interval_units: "month" }`
3. `{ subscribable_id: 1, interval_length: 2, interval_units: "month" }`

This will generate 2 subscriptions: the first related to subscription line items 1 and 2, and the
second related to subscription line item 3.

### Processing subscriptions

To process actionable subscriptions simply run:

```bash
$ bundle exec rake solidus_subscriptions:process
```

The task creates ActiveJob jobs which can be fulfilled by your queue library of choice.

We suggest using the [Whenever](https://github.com/javan/whenever) gem to schedule the task.

### Promotion rules
This extensions adds the following [Promotion rules](https://guides.solidus.io/developers/promotions/promotion-rules.html):
* `SolidusSubscriptions::Promotion::Rules::SubscriptionCreationOrder` which applies if the order is creating a subscription;
* `SolidusSubscriptions::Promotion::Rules::SubscriptionInstallmentOrder` which applies if the order is an installment of a subscription.

### API documentation

You can find the API documentation [here](https://stoplight.io/p/docs/gh/solidusio-contrib/solidus_subscriptions?group=master).

### Churn Buster integration

This extension optionally integrates with [Churn Buster](https://churnbuster.io) for failed payment
recovery. In order to enable the integration, simply add your Churn Buster credentials to your
configuration:

```ruby
SolidusSubscriptions.configure do |config|
  # ...

  config.churn_buster_account_id = 'YOUR_CHURN_BUSTER_ACCOUNT_ID'
  config.churn_buster_api_key = 'YOUR_CHURN_BUSTER_API_KEY'
end
```

The extension will take care of reporting successful/failed payments and payment method changes
to Churn Buster.

### Failed installments retries

The extension generates an installment for each subscription cycle, however some of them can fail
(e.g. for an expired credit card). On each processor run the extension will try to complete all past
failed installments, however this is not always the desired behaviour.

If you want to process only the latest installment in each subscription, regardless of any number of
failed installments prior to that, you can configure the extension like so:

```ruby
SolidusSubscriptions.configure do |config|
  # ...

  config.clear_past_installments = true
end
```

### Minimum cancellation notice

The minimum cancellation notice is set to 0 days by default - users can cancel their subscription whenever they like. To change this, you can configure the extension like this:

```ruby
SolidusSubscriptions.configure do |config|
  # ...

  config.minimum_cancellation_notice = 10.days
end
```

### Subscription product deletion
When a product is soft deleted, its subscription line items need to be deleted as well, in order to avoid error on subscription processing.
If the product class is `Spree::Variant`, this corner case is handled automatically on the variant soft deletion, otherwise it should be handled manually.

## Development

### Testing the extension

First bundle your dependencies, then run `bin/rake`. `bin/rake` will default to building the dummy
app if it does not exist, then it will run specs. The dummy app can be regenerated by using
`bin/rake extension:test_app`.

```shell
bin/rake
```

To run [Rubocop](https://github.com/bbatsov/rubocop) static code analysis run

```shell
bundle exec rubocop
```

When testing your application's integration with this extension you may use its factories.
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_subscriptions/factories'
```

### Running the sandbox

To run this extension in a sandboxed Solidus application, you can run `bin/sandbox`. The path for
the sandbox app is `./sandbox` and `bin/rails` will forward any Rails commands to
`sandbox/bin/rails`.

Here's an example:

```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
* Listening on tcp://127.0.0.1:3000
Use Ctrl-C to stop
```

### Updating the changelog

Before and after releases the changelog should be updated to reflect the up-to-date status of
the project:

```shell
bin/rake changelog
git add CHANGELOG.md
git commit -m "Update the changelog"
```

### Releasing new versions

Your new extension version can be released using `gem-release` like this:

```shell
bundle exec gem bump -v 1.6.0
bin/rake changelog
git commit -a --amend
git push
bundle exec gem release
```

## License

Copyright (c) 2016 Stembolt, released under the New BSD License

Originally sponsored by [Goby](https://www.goby.co).
