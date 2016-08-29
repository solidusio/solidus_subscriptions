require 'rails_helper'

RSpec.describe SolidusSubscriptions::LineItem, type: :model do
  it { is_expected.to belong_to :spree_line_item }
  it { is_expected.to belong_to :subscription }

  it { is_expected.to validate_presence_of :spree_line_item }
  it { is_expected.to validate_presence_of :subscribable_id }

  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:max_installments).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:interval).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:max_installments).allow_nil }
end
