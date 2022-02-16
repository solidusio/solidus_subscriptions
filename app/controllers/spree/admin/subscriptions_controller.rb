module Spree
  module Admin
    class SubscriptionsController < ResourceController
      skip_before_action :load_resource, only: :index
      before_action :set_store_id, only: [:create]

      def index
        @search = SolidusSubscriptions::Subscription.order(:actionable_date).
          accessible_by(current_ability, :index).ransack(params[:q])

        @subscriptions = @search.result(distinct: true).
          includes(:line_items, :user).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      def new
        @subscription.line_items.new
      end

      def cancel
        @subscription.transaction do
          @subscription.actionable_date = nil
          @subscription.cancel
        end

        if @subscription.errors.none?
          notice = I18n.t('spree.admin.subscriptions.successfully_canceled')
        else
          notice = @subscription.errors.full_messages.to_sentence
        end

        redirect_to spree.admin_subscriptions_path, notice: notice
      end

      def activate
        @subscription.activate

        if @subscription.errors.none?
          notice = I18n.t('spree.admin.subscriptions.successfully_activated')
        else
          notice = @subscription.errors.full_messages.to_sentence
        end

        redirect_to spree.admin_subscriptions_path, notice: notice
      end

      def skip
        @subscription.advance_actionable_date

        notice = I18n.t(
          'spree.admin.subscriptions.successfully_skipped',
          date: @subscription.actionable_date
        )

        redirect_to spree.admin_subscriptions_path, notice: notice
      end

      private

      def set_store_id
        params[:subscription].merge!(store_id: ::Spree::Store.default.id)
      end

      def model_class
        ::SolidusSubscriptions::Subscription
      end
    end
  end
end
