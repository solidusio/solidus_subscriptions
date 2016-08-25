require 'rails_helper'

RSpec.describe SolidusSubscriptions::Installment, type: :model do
  it { is_expected.to have_many :details }
  it { is_expected.to belong_to :order }
  it { is_expected.to belong_to :subscription }

  it { is_expected.to validate_presence_of :subscription }
end
