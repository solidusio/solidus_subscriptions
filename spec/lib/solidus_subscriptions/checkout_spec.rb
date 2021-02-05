RSpec.describe SolidusSubscriptions::Checkout, :checkout do
  context 'when the order can be created and paid' do
    it 'creates and finalizes a new order for the installment' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable)

      order = described_class.new(installment).process

      expect(order).to be_complete
      expect(order).to be_paid
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'copies basic information from the subscription' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable)
      subscription = installment.subscription

      order = described_class.new(installment).process

      expect(order.ship_address.value_attributes).to eq(subscription.shipping_address_to_use.value_attributes)
      expect(order.bill_address.value_attributes).to eq(subscription.billing_address_to_use.value_attributes)
      expect(order.payments.first.payment_method).to eq(subscription.payment_method_to_use)
      expect(order.payments.first.source).to eq(subscription.payment_source_to_use)
      expect(order.user).to eq(subscription.user)
      expect(order.email).to eq(subscription.user.email)
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'marks the order as a subscription order' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable)
      subscription = installment.subscription

      order = described_class.new(installment).process

      expect(order.subscription).to eq(subscription)
      expect(order.subscription_order).to eq(true)
    end

    it 'matches the total on the subscription' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable)
      subscription = installment.subscription

      order = described_class.new(installment).process

      expect(order.item_total).to eq(subscription.line_items.first.subscribable.price)
    end

    it 'calls the success dispatcher' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable)
      success_dispatcher = stub_dispatcher(SolidusSubscriptions::Dispatcher::SuccessDispatcher, installment)

      described_class.new(installment).process

      expect(success_dispatcher).to have_received(:dispatch)
    end
  end

  context 'when payment of the order fails' do
    it 'calls the payment failed dispatcher' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable).tap do |i|
        i.subscription.update!(payment_source: create(:credit_card, number: '4111123412341234'))
      end
      payment_failed_dispatcher = stub_dispatcher(SolidusSubscriptions::Dispatcher::PaymentFailedDispatcher, installment)

      described_class.new(installment).process

      expect(payment_failed_dispatcher).to have_received(:dispatch)
    end
  end

  context 'when an item is out of stock' do
    it 'calls the out of stock dispatcher' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable).tap do |i|
        i.subscription.line_items.first.subscribable.stock_items.each do |stock_item|
          stock_item.update!(backorderable: false)
        end
      end
      out_of_stock_dispatcher = stub_dispatcher(SolidusSubscriptions::Dispatcher::OutOfStockDispatcher, installment)

      described_class.new(installment).process

      expect(out_of_stock_dispatcher).to have_received(:dispatch)
    end
  end

  context 'when a generic transition error happens during checkout' do
    it 'calls the failure dispatcher' do
      stub_spree_preferences(auto_capture: true)
      installment = create(:installment, :actionable)
      failure_dispatcher = stub_dispatcher(SolidusSubscriptions::Dispatcher::FailureDispatcher, installment)
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Spree::Order).to receive(:next!)
        .and_raise(StateMachines::InvalidTransition.new(
          Spree::Order.new,
          Spree::Order.state_machines[:state],
          :next,
        ))
      # rubocop:enable RSpec/AnyInstance

      described_class.new(installment).process

      expect(failure_dispatcher).to have_received(:dispatch)
    end
  end

  private

  def stub_dispatcher(klass, installment)
    instance_spy(klass).tap do |dispatcher|
      allow(klass).to receive(:new).with(
        installment,
        an_instance_of(Spree::Order)
      ).and_return(dispatcher)
    end
  end
end
