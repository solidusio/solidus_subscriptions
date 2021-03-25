# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Spree::LineItem::SubscriptionLineItemsAssociation, type: :model do
  subject { Spree::LineItem.new }

  it { is_expected.to have_many :subscription_line_items }
  it { is_expected.to accept_nested_attributes_for :subscription_line_items }
end
