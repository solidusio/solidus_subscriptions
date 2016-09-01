FactoryGirl.define do
  factory :installment, class: 'SolidusSubscriptions::Installment' do
    association :subscription, factory: [:subscription, :with_line_item]
  end
end
