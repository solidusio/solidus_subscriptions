# frozen_string_literal: true

module Spree
  module Admin
    class SubscriptionOrdersController < ResourceController
      belongs_to 'subscription', model_class: SolidusSubscriptions::Subscription

      def index
        @search = collection.ransack((params[:q] || {}).reverse_merge(s: 'created_at desc'))

        @subscription_orders = @search.result(distinct: true).
                               page(params[:page]).
                               per(params[:per_page] || 20)
      end

      private

      def model_class
        ::Spree::Order
      end

      def find_resource
        parent.orders.find(params[:id])
      end

      def build_resource
        parent.orders.build
      end

      def collection
        parent.orders
      end
    end
  end
end
