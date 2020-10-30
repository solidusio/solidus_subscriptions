# frozen_string_literal: true

Deface::Override.new(
  virtual_path: 'spree/admin/users/_tabs',
  name: 'solidus_subscriptions_admin_users_subscriptions_tab',
  insert_bottom: "[data-hook='admin_user_tab_options']",
  partial: 'spree/admin/users/subscription_tab'
)
