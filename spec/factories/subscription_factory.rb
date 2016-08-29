FactoryGirl.define do
  factory :subscription, class: 'SolidusSubscriptions::Subscription' do
    user
end
