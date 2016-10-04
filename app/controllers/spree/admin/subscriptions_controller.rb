module Spree
  module Admin
    class SubscriptionsController < ResourceController
      def index
      end

      private

      def model_class
        ::SolidusSubscriptions::Subscription
      end
    end
  end
end
