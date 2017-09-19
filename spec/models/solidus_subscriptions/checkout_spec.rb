require 'rails_helper'

RSpec.describe SolidusSubscriptions::Checkout do
  let(:checkout) { described_class.new(installments) }
  let(:root_order) { create :completed_order_with_pending_payment }
  let(:subscription_user) do
    create(:user, :subscription_user).tap do |user|
      create(:credit_card, gateway_customer_profile_id: 'BGS-123', user: user, default: true)
    end
  end
  let(:installments) { create_list(:installment, 2, installment_traits) }

  let(:installment_traits) do
    {
      subscription_traits: [{
        user: subscription_user,
        line_item_traits: [{
          spree_line_item: root_order.line_items.first
        }]
      }]
    }
  end

  context 'initialized with installments belonging to multiple users' do
    subject { checkout }
    let(:installments) { build_stubbed_list :installment, 2 }

    it 'raises an error' do
      expect { subject }.
        to raise_error SolidusSubscriptions::UserMismatchError, /must have the same user/
    end
  end

  describe '#process', :checkout do
    subject(:order) { checkout.process }
    let(:subscription_line_item) { installments.first.subscription.line_items.first }

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

      it 'associates the order to the installment detail' do
        order
        installment_orders = installments.flat_map { |i| i.details.map(&:order) }.compact
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

    if Gem::Specification.all.find{ |gem| gem.name == 'solidus' }.version >= Gem::Version.new('1.4.0')
      context 'Altered checkout flow' do
        before do
          @old_checkout_flow = Spree::Order.checkout_flow
          Spree::Order.remove_checkout_step(:delivery)
        end

        after do
          Spree::Order.checkout_flow(&@old_checkout_flow)
        end

        it 'has a payment' do
          expect(order.payments.valid).to be_present
        end

        it 'has the correct totals' do
          expect(order).to have_attributes(
            total: 39.98,
            shipment_total: 0
          )
        end

        it { is_expected.to be_complete }
      end
    end

    context 'the variant is out of stock' do
      let(:subscription_line_item) { installments.last.subscription.line_items.first }

      # Remove stock for 1 variant in the consolidated installment
      before do
        subscribable_id = installments.first.subscription.line_items.first.subscribable_id
        variant = Spree::Variant.find(subscribable_id)
        variant.stock_items.update_all(count_on_hand: 0, backorderable: false)
      end

      let(:expected_date) { (DateTime.current + SolidusSubscriptions::Config.reprocessing_interval).beginning_of_minute }

      it 'creates a failed installment detail' do
        subject
        detail = installments.first.details.last

        expect(detail).to_not be_successful
        expect(detail.message).
          to eq I18n.t('solidus_subscriptions.installment_details.out_of_stock')
      end

      it 'removes the installment from the list of installments' do
        expect { subject }.
          to change { checkout.installments.length }.
          by(-1)
      end

      it_behaves_like 'a completed checkout' do
        let(:total) { 29.99 }
        let(:quantity) { installments.length - 1 }
      end
    end

    context 'the payment fails' do
      let!(:credit_card) { 
        card = create(:credit_card, user: checkout.user, default: true) 
        if SolidusSupport.solidus_gem_version >= Gem::Version.new("2.2.0")
          wallet_payment_source = checkout.user.wallet.add(card)
          checkout.user.wallet.default_wallet_payment_source = wallet_payment_source
        end
        card
      }
      let(:expected_date) { (DateTime.current + SolidusSubscriptions::Config.reprocessing_interval).beginning_of_minute }

      it { is_expected.to be_nil }

      it 'marks all of the installments as failed' do
        subject

        details = installments.map do |installments|
          installments.details.reload.last
        end

        expect(details).to all be_failed && have_attributes(
          message: I18n.t('solidus_subscriptions.installment_details.payment_failed')
        )
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

    context 'there is an aribitrary failure' do
      let(:expected_date) { (DateTime.current + SolidusSubscriptions::Config.reprocessing_interval).beginning_of_minute }

      before do
        allow(checkout).to receive(:populate).and_raise('arbitrary runtime error')
      end

      it 'advances the installment actionable dates', :aggregate_failures do
        expect { subject }.to raise_error('arbitrary runtime error')

        actionable_dates = installments.map do |installment|
          installment.reload.actionable_date
        end

        expect(actionable_dates).to all eq expected_date
      end
    end

    context 'the user has store credit' do
      it_behaves_like 'a completed checkout'
      let!(:store_credit) { create :store_credit, user: subscription_user }

      it 'has a valid store credit payment' do
        expect(order.payments.valid.store_credits).to be_present
      end
    end

    context 'the subscription has a shipping address' do
      it_behaves_like 'a completed checkout'
      let(:shipping_address) { create :address }
      let(:installment_traits) do
        {
          subscription_traits: [{
            shipping_address: shipping_address,
            user: subscription_user,
            line_item_traits: [{ spree_line_item: root_order.line_items.first }]
          }]
        }
      end

      it 'ships to the subscription address' do
        expect(subject.ship_address).to eq shipping_address
      end
    end

    context 'there are multiple associated subscritpion line items' do
      it_behaves_like 'a completed checkout' do
        let(:quantity) { subscription_line_items.length }
      end

      let(:installments) { create_list(:installment, 1, installment_traits) }
      let(:subscription_line_items) { create_list(:subscription_line_item, 2, quantity: 1) }

      let(:installment_traits) do
        {
          subscription_traits: [{
            user: subscription_user,
            line_items: subscription_line_items
          }]
        }
      end
    end
  end

  describe '#order' do
    subject { checkout.order }
    let(:user) { installments.first.subscription.user }

    it { is_expected.to be_a Spree::Order }

    it 'has the correct attributes' do
      expect(subject).to have_attributes(
        user: user,
        email: user.email,
        store: installments.first.subscription.store
      )
    end

    it 'is the same instance any time its called' do
      order = checkout.order
      expect(subject).to equal order
    end
  end
end
