require 'spec_helper'

RSpec.describe Spree::User, type: :model do
  it { is_expected.to have_many :subscriptions }
  it { is_expected.to accept_nested_attributes_for :subscriptions }
end
