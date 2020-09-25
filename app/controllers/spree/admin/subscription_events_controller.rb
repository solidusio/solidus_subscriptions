# frozen_string_literal: true

module Spree
  module Admin
    class SubscriptionEventsController < ResourceController
      belongs_to 'subscription', model_class: SolidusSubscriptions::Subscription

      skip_before_action :load_resource, only: :index

      def index
        @search = collection.ransack((params[:q] || {}).reverse_merge(s: 'created_at desc'))

        @subscription_events = @search.result(distinct: true).
                               page(params[:page]).
                               per(params[:per_page] || 20)
      end

      private

      def model_class
        ::SolidusSubscriptions::SubscriptionEvent
      end

      def find_resource
        parent.events.find(params[:id])
      end

      def build_resource
        parent.events.build
      end

      def collection
        parent.events
      end
    end
  end
end
