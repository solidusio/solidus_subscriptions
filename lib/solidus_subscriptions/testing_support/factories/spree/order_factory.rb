FactoryBot.modify do
  factory :order do
    trait :with_subscription_line_items do
      transient do
        n_line_items { 1 }
      end

      line_items do
        build_list(
          :line_item,
          n_line_items,
          :with_subscription_line_items,
          order: @instance
        )
      end
    end
  end
end
