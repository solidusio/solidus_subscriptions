require 'spec_helper'

RSpec.describe Spree::Users::HaveManySubscritptions, type: :model do
  subject { Spree::User.new }

  it { is_expected.to have_many :subscriptions }
  it { is_expected.to accept_nested_attributes_for :subscriptions }
end
