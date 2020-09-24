# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "spree/admin/variants/_form",
  name: "solidus_subscriptions_variant_subscribable_checkbox",
  insert_after: "[data-hook='track_inventory']",
  partial: "spree/admin/variants/subscribable_checkbox"
)
