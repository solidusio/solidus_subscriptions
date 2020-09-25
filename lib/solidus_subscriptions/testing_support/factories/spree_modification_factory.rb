# frozen_string_literal: true

FactoryBot.modify do
  factory :user do
    trait :subscription_user do
      bill_address
      ship_address
    end
  end
end
