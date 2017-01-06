FactoryGirl.define do
  factory :subscription, class: 'SolidusSubscriptions::Subscription' do
    store

    user do
      ccs = build_list(:credit_card, 1, gateway_customer_profile_id: 'BGS-123', default: true)
      build :user, :subscription_user, credit_cards: ccs
    end

    trait :with_line_item do
      transient do
        line_item_traits []
      end

      line_item { build :subscription_line_item, *line_item_traits }
    end

    trait :actionable do
      with_line_item
      actionable_date { Time.zone.now.yesterday }
    end

    trait :not_actionable do
      with_line_item
      actionable_date { Time.zone.now.tomorrow }
    end

    trait(:pending_cancellation) do
      actionable
      state { 'pending_cancellation' }
    end

    trait(:canceled) { state 'canceled' }
    trait(:inactive) { state 'inactive' }
  end
end
