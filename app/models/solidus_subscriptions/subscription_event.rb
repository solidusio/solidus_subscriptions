# frozen_string_literal: true

module SolidusSubscriptions
  class SubscriptionEvent < ApplicationRecord
    belongs_to :subscription, class_name: 'SolidusSubscriptions::Subscription', inverse_of: :events

    after_initialize do
      self.details ||= {}
    end
  end
end
