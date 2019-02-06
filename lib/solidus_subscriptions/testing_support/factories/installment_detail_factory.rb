FactoryBot.define do
  factory :installment_detail, class: 'SolidusSubscriptions::InstallmentDetail' do
    installment

    trait(:success) {
      success { true }
    }
  end
end
