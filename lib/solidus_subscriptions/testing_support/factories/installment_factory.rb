# frozen_string_literal: true

FactoryBot.define do
  factory :installment, class: 'SolidusSubscriptions::Installment' do
    transient {
      subscription_traits { [] }
    }
    subscription { association(:subscription, :with_line_item, *subscription_traits) }

    trait :failed do
      actionable_date { Time.zone.yesterday }
      details { [association(:installment_detail, installment: @instance)] }
    end

    trait :success do
      transient do
        order { create :completed_order_with_totals }
      end

      details do
        [association(:installment_detail, :success, installment: @instance, order: order)]
      end
    end

    trait :actionable do
      actionable_date { Time.zone.now }
    end
  end
end
