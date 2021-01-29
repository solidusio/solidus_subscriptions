require 'spec_helper'

RSpec.describe SolidusSubscriptions::Spree::User::HaveManySubscriptions, type: :model do
  subject { Spree::User.new }

  it { is_expected.to have_many :subscriptions }
  it { is_expected.to accept_nested_attributes_for :subscriptions }
end
