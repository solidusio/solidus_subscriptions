# frozen_string_literal: true

module Spree
  module Admin
    module Users
      class SubscriptionsController < ResourceController
        belongs_to 'spree/user', model_class: Spree.user_class

        private

        def model_class
          ::SolidusSubscriptions::Subscription
        end
      end
    end
  end
end
