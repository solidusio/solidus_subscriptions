FactoryGirl.define do
  factory :installment, class: 'SolidusSubscriptions::Installment' do
    transient { subscription_traits [] }
    subscription { build :subscription, :with_line_item, *subscription_traits }

    trait :failed do
      actionable_date { Time.zone.yesterday }
      details { build_list(:installment_detail, 1, installment: @instance) }
    end

    trait :success do
      order { create :completed_order_with_totals }
      details { build_list(:installment_detail, 1, :success, installment: @instance) }
    end
  end
end
