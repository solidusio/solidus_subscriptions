# This class represents a single attempt to fulfill an installment. It will
# indicate the result of that attept.
module SolidusSubscriptions
  class InstallmentDetail < ActiveRecord::Base
    belongs_to(
      :installment,
      class_name: 'SolidusSubscriptions::Installment',
      inverse_of: :details
    )

    validates :state, :installment, presence: true
  end
end
