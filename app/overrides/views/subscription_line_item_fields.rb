# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "subscription_line_item_fields",
  insert_after: "[data-hook='inside_product_cart_form']",
  partial: "spree/frontend/products/subscription_line_item_fields"
)
