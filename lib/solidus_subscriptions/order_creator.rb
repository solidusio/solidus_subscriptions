# frozen_string_literal: true

module SolidusSubscriptions
  class OrderCreator
    def initialize(installment)
      @installment = installment
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

    private

    def extra_attributes
      {}
    end

    attr_reader :installment
  end
end
