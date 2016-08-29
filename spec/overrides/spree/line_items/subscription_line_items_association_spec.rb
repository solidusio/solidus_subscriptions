require 'rails_helper'

RSpec.describe Spree::LineItems::SubscriptionLineItemsAssociation, type: :model do
  subject { Spree::LineItem.new }
  it { is_expected.to have_many :subscription_line_items }
end
