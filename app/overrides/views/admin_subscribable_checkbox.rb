Deface::Override.new(
  virtual_path: "spree/admin/variants/_form",
  name: "solidus_subscriptions_subscribable_checkbox",
  insert_after: "[data-hook='track_inventory']",
  partial: "spree/admin/variants/subscribable_checkbox"
)

Deface::Override.new(
  virtual_path: "spree/admin/products/_form",
  name: "solidus_subscriptions_product_subscribable_checkbox",
  insert_after: "[data-hook='admin_product_form_meta']",
  partial: "spree/admin/products/subscribable_checkbox"
)
