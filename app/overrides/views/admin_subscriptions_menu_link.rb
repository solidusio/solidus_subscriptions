# frozen_string_literal: true

if !Spree::Backend::Config.respond_to?(:menu_items)
  Deface::Override.new(
    virtual_path: 'spree/admin/shared/_menu',
    name: :add_subcriptions_admin_link,
    insert_bottom: "[data-hook='admin_tabs']",
    partial: 'spree/admin/shared/subscription_tab'
  )
end
