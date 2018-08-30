FactoryBot.modify do
  factory :line_item do
    trait :with_subscription_line_items do
      transient do
        n_subscription_line_items { 1 }
      end

      subscription_line_items do
        build_list(
          :subscription_line_item,
          n_subscription_line_items,
          spree_line_item: @instance
        )
      end
    end
  end
end
