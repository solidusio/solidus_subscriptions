FactoryGirl.define do
  factory :installment_detail, class: 'SolidusSubscriptions::InstallmentDetail' do
    installment
  end
end
