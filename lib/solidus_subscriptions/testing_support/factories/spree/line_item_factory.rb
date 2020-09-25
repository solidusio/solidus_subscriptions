# frozen_string_literal: true

FactoryBot.modify do
  factory :line_item do
    trait :with_subscription_line_items do
      transient do
        n_subscription_line_items { 1 }
      end

      subscription_line_items do
        Array.new(n_subscription_line_items) do
          association :subscription_line_item, spree_line_item: @instance
        end
      end
    end
  end
end
