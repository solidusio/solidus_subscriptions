require 'spec_helper'

RSpec.describe SolidusSubscriptions::ProcessInstallmentsJob do
  let(:root_order) { create :completed_order_with_pending_payment }
  let(:installments) do
    traits = {
      subscription_traits: [{
        user: root_order.user,
        line_item_traits: [{
          spree_line_item: root_order.line_items.first
        }]
      }]
    }

    create_list(:installment, 2, traits)
  end

  describe '#perform' do
    subject { described_class.new.perform(installments) }

    it 'processes the consolidated installment' do
      expect_any_instance_of(SolidusSubscriptions::Checkout).
        to receive(:process).once

      subject
    end
  end
end
