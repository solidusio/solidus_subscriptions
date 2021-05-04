# frozen_string_literal: true

module SolidusSubscriptions
  class OrderCreator
    def initialize(installment, extra_attributes)
      @installment = installment
      @extra_attributes = (extra_attributes || {}).symbolize_keys
    end

    def call
      ::Spree::Order.create(
        user: installment.subscription.user,
        email: installment.subscription.user.email,
        store: installment.subscription.store || ::Spree::Store.default,
        subscription_order: true,
        subscription: installment.subscription,
        currency: installment.subscription.currency,
        **extra_attributes
      )
    end

    protected

    attr_reader :installment, :extra_attributes
  end
end
