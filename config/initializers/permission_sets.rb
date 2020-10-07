# frozen_string_literal: true

Spree.config do |config|
  config.roles.assign_permissions :default, %w[
    SolidusSubscriptions::PermissionSets::SubscriptionManagement
  ]
end
