# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Spree::Order::InstallmentDetailsAssociation, type: :model do
  subject { Spree::Order.new }

  it { is_expected.to have_many :installment_details }
end
