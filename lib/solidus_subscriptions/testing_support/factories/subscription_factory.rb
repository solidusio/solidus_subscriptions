FactoryBot.define do
  factory :subscription, class: 'SolidusSubscriptions::Subscription' do
    store
    interval_length { 1 }
    interval_units { :month }

    user do
      new_user = create(:user, :subscription_user)
      card = create(:credit_card, gateway_customer_profile_id: 'BGS-123', user: new_user)
      wallet_payment_source = new_user.wallet.add(card)
      new_user.wallet.default_wallet_payment_source = wallet_payment_source
      new_user
    end

    trait :with_line_item do
      transient do
        line_item_traits { [] }
      end

      line_items { build_list :subscription_line_item, 1, *line_item_traits }
    end

    trait :with_address do
      association :shipping_address, factory: :address
    end

    trait :actionable do
      with_line_item
      actionable_date { Time.zone.now.yesterday.beginning_of_minute }
    end

    trait :not_actionable do
      with_line_item
      actionable_date { Time.zone.now.tomorrow.beginning_of_minute }
    end

    trait(:pending_cancellation) do
      actionable
      state { 'pending_cancellation' }
    end

    trait(:canceled) {
      state { 'canceled' }
    }
    trait(:inactive) {
      state { 'inactive' }
    }
  end
end
