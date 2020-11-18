# frozen_string_literal: true

# This class represents a single attempt to fulfill an installment. It will
# indicate the result of that attempt.
module SolidusSubscriptions
  class InstallmentDetail < ApplicationRecord
    belongs_to(
      :installment,
      class_name: 'SolidusSubscriptions::Installment',
      inverse_of: :details
    )

    belongs_to(:order, class_name: '::Spree::Order', optional: true)

    validates :installment, presence: true
    alias_attribute :successful, :success

    scope :succeeded, -> { where success: true }
    scope :failed, -> { where success: false }

    # Was the attempt at fulfilling this installment a failure?
    #
    # @return [Boolean]
    def failed?
      !success
    end
  end
end
