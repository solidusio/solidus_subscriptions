# This class attaches installments to promotion so that when an order is checked out
# it can get a promotion added
module SolidusSubscriptions
  class InstallmentPromotion < ActiveRecord::Base
    belongs_to :installment, class_name: 'SolidusSubscriptions::Installment'
    belongs_to :promotion, class_name: 'Spree::Promotion'
    belongs_to :promotion_code, class_name: 'Spree::PromotionCode'
  end
end
