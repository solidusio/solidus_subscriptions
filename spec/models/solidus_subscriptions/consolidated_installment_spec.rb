require 'rails_helper'

RSpec.describe SolidusSubscriptions::ConsolidatedInstallment do
  let(:consolidated_installment) { described_class.new(installments) }
  let(:root_order) { create :completed_order_with_pending_payment }
  let(:subscription_user) { create :user }
  let(:installments) do
    traits = {
      subscription_traits: [{
        user: subscription_user,
        line_item_traits: [{
          spree_line_item: root_order.line_items.first
        }]
      }]
    }

    create_list(:installment, 2, traits)
  end

  describe '#process', :checkout do
    subject(:order) { consolidated_installment.process }
    let(:subscription_line_item) { installments.first.subscription.line_item }

    shared_examples 'a completed checkout' do
      it { is_expected.to be_a Spree::Order }
      let(:total) { 49.98 }
      let(:quantity) { installments.length }

      it 'has the correct number of line items' do
        count = order.line_items.length
        expect(count).to eq quantity
      end

      it 'the line items have the correct values' do
        line_item = order.line_items.first
        expect(line_item).to have_attributes(
          quantity: subscription_line_item.quantity,
          variant_id: subscription_line_item.subscribable_id
        )
      end

      it 'has a shipment' do
        expect(order.shipments).to be_present
      end

      it 'has a payment' do
        expect(order.payments.valid).to be_present
      end

      it 'has the correct totals' do
        expect(order).to have_attributes(
          total: total,
          shipment_total: 10
        )
      end

      it { is_expected.to be_complete }

      it 'associates the order to the installments' do
        order
        installment_orders = installments.map { |i| i.reload.order }.compact
        expect(installment_orders).to all eq order
      end

      it 'creates an installment detail for each installment' do
        expect { subject }.
          to change { SolidusSubscriptions::InstallmentDetail.count }.
          by(installments.count)
      end
    end

    context 'no line items get added to the cart' do
      before do
        installments
        Spree::StockItem.update_all(count_on_hand: 0, backorderable: false)
      end

      it 'creates two failed installment details' do
        expect { order }.
          to change { SolidusSubscriptions::InstallmentDetail.count }.
          by(installments.length)

        details = SolidusSubscriptions::InstallmentDetail.last(installments.length)
        expect(details).to all be_failed
      end

      it { is_expected.to be_nil }

      it 'creates no order' do
        expect { subject }.to_not change { Spree::Order.count }
      end
    end

    context 'the user has addresss and active card' do
      let(:credit_card) { create(:credit_card, gateway_customer_profile_id: 'BGS-123', default: true) }

      before do
        consolidated_installment.user.credit_cards << credit_card
        consolidated_installment.user.update ship_address: create(:address)
      end

      it_behaves_like 'a completed checkout'

      it 'uses the root order address' do
        expect(order.ship_address).to eq consolidated_installment.user.ship_address
      end

      it 'uses the root orders last payment method' do
        source = order.payments.last.source
        expect(source).to eq credit_card
      end
    end

    context 'the user has no address or active card' do
      it_behaves_like 'a completed checkout'

      it 'uses the root order address' do
        expect(order.ship_address).to eq consolidated_installment.root_order.ship_address
      end

      it 'uses the root orders last payment method' do
        source = order.payments.last.source
        expect(source).to eq consolidated_installment.root_order.payments.last.source
      end
    end

    context 'the variant is out of stock' do
      let(:subscription_line_item) { installments.last.subscription.line_item }

      # Remove stock for 1 variant in the consolidated installment
      before do
        subscribable_id = installments.first.subscription.line_item.subscribable_id
        variant = Spree::Variant.find(subscribable_id)
        variant.stock_items.update_all(count_on_hand: 0, backorderable: false)
      end

      let(:expected_date) { Date.current + SolidusSubscriptions::Config.reprocessing_interval }

      it 'creates a failed installment detail' do
        subject
        detail = installments.first.details.last

        expect(detail).to_not be_successful
        expect(detail.message).
          to eq I18n.t('solidus_subscriptions.installment_details.out_of_stock')
      end

      it 'removes the installment from the list of installments' do
        expect { subject }.
          to change { consolidated_installment.installments.length }.
          by(-1)
      end

      it_behaves_like 'a completed checkout' do
        let(:total) { 29.99 }
        let(:quantity) { installments.length - 1 }
      end
    end

    context 'the payment fails' do
      let(:credit_card) { create(:credit_card, default: true) }
      let(:expected_date) { Date.current + SolidusSubscriptions::Config.reprocessing_interval }

      before do
        consolidated_installment.user.credit_cards << credit_card
      end

      it { is_expected.to be_nil }

      it 'marks all of the installments as failed' do
        subject

        details = installments.map do |installments|
          installments.details(true).last
        end

        expect(details).to all be_failed && have_attributes(
          message: I18n.t('solidus_subscriptions.installment_details.payment_failed')
        )
      end

      it 'creates no order' do
        expect { subject }.to_not change { Spree::Order.count }
      end

      it 'marks the installment to be reprocessed' do
        subject
        actionable_dates = installments.map do |installment|
          installment.reload.actionable_date
        end

        expect(actionable_dates).to all eq expected_date
      end
    end

    context 'when there are cart promotions' do
      let!(:promo) do
        create(
          :promotion,
          :with_item_total_rule,
          :with_order_adjustment,
          promo_params
        )
      end

      # Promotions require the :apply_automatically flag to be auto applied in
      # solidus versions greater than 1.0
      let(:promo_params) do
        {}.tap do |params|
          if Spree::Promotion.new.respond_to?(:apply_automatically)
            params[:apply_automatically] = true
          end
        end
      end

      it_behaves_like 'a completed checkout' do
        let(:total) { 39.98 }
      end

      it 'applies the correct adjustments' do
        expect(subject.adjustments).to be_present
      end
    end
  end

  describe '#order' do
    subject { consolidated_installment.order }
    let(:user) { installments.first.subscription.user }

    it { is_expected.to be_a Spree::Order }

    it 'has the correct attributes' do
      expect(subject).to have_attributes(
        user: user,
        email: user.email,
        store: root_order.store
      )
    end

    it 'is the same instance any time its called' do
      order = consolidated_installment.order
      expect(subject).to equal order
    end
  end
end
