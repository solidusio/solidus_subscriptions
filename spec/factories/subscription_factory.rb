FactoryGirl.define do
  factory :subscription, class: 'SolidusSubscriptions::Subscription' do
    user

    trait :with_line_item do
      transient do
        line_item_traits []
      end

      line_item { build :subscription_line_item, *line_item_traits }
    end
  end
end
