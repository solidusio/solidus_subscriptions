require 'rails_helper'

RSpec.describe SolidusSubscriptions::InstallmentDetail, type: :model do
  it { is_expected.to belong_to :installment }

  it { is_expected.to validate_presence_of :installment }
  it { is_expected.to validate_presence_of :state }
end
