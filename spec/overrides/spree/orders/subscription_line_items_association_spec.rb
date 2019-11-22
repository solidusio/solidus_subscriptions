require 'spec_helper'

RSpec.describe Spree::Orders::SubscriptionLineItemsAssociation, type: :model do
  subject { Spree::Order.new }

  it { is_expected.to have_many :subscription_line_items }
end
