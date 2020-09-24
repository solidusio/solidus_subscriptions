# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "spree/admin/products/_form",
  name: "solidus_subscriptions_product_subscribable_checkbox",
  insert_after: "[data-hook='admin_product_form_promotionable']",
  partial: "spree/admin/products/subscribable_checkbox"
)
