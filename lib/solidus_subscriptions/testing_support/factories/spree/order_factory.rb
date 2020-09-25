# frozen_string_literal: true

FactoryBot.modify do
  factory :order do
    trait :with_subscription_line_items do
      transient do
        n_line_items { 1 }
      end

      line_items do
        Array.new(n_line_items) do
          association :line_item, :with_subscription_line_items, order: @instance
        end
      end
    end
  end
end
