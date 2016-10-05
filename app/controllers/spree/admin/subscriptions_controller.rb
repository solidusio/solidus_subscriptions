module Spree
  module Admin
    class SubscriptionsController < ResourceController
      skip_before_filter :load_resource, only: :index

      def index
        @search = SolidusSubscriptions::Subscription.
          accessible_by(current_ability, :index).ransack(params[:q])

        @subscriptions = @search.result(distinct: true).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      private

      def model_class
        ::SolidusSubscriptions::Subscription
      end
    end
  end
end
