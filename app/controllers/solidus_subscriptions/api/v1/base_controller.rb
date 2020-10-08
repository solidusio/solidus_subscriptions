# frozen_string_literal: true

module SolidusSubscriptions
  module Api
    module V1
      class BaseController < ::Spree::Api::BaseController
        def subscription_guest_token
          request.headers['X-Spree-Subscription-Token']
        end
      end
    end
  end
end
