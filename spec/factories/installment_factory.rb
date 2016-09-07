FactoryGirl.define do
  factory :installment, class: 'SolidusSubscriptions::Installment' do
    transient { subscription_traits [] }
    subscription { build :subscription, :with_line_item, *subscription_traits }
  end
end
