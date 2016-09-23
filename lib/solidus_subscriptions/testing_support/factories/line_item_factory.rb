FactoryGirl.define do
  factory :subscription_line_item, class: 'SolidusSubscriptions::LineItem' do
    subscribable_id { create(:variant, subscribable: true).id }
    quantity 1
    interval_length 1
    interval_units :months

    association :spree_line_item, factory: :line_item

    trait :with_subscription do
      transient do
        subscription_traits []
      end

      subscription { build :subscription, *subscription_traits }
    end
  end
end
