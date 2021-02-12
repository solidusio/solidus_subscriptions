# frozen_string_literal: true

module Spree
  module Admin
    class SubscriptionsController < ResourceController
      skip_before_action :load_resource, only: :index

      def index
        @search = SolidusSubscriptions::Subscription.accessible_by(current_ability).ransack(params[:q])
        @subscriptions = @search.result(distinct: true).
                         includes(:line_items, :user).
                         page(params[:page]).
                         per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      def new
        prepare_form
      end

      def edit
        prepare_form
        load_payment_methods
      end

      def update
        load_payment_methods
        @subscription.payment_method_id = params[:subscription][:payment_method_id]

        if @subscription.payment_method&.source_required?
          @subscription.payment_source = @subscription
                                         .payment_method
                                         .payment_source_class
                                         .find_by(id: params[:subscription][:payment_source_id])
        else
          @subscription.payment_source = nil
        end

        super
      end

      def cancel
        @subscription.transaction do
          @subscription.actionable_date = nil
          @subscription.cancel
        end

        notice = if @subscription.errors.none?
                   I18n.t('spree.admin.subscriptions.successfully_canceled')
                 else
                   @subscription.errors.full_messages.to_sentence
                 end

        redirect_back(fallback_location: spree.admin_subscriptions_path, notice: notice)
      end

      def activate
        @subscription.activate

        notice = if @subscription.errors.none?
                   I18n.t('spree.admin.subscriptions.successfully_activated')
                 else
                   @subscription.errors.full_messages.to_sentence
                 end

        redirect_back(fallback_location: spree.admin_subscriptions_path, notice: notice)
      end

      def skip
        @subscription.skip(check_skip_limits: false)

        notice = I18n.t(
          'spree.admin.subscriptions.successfully_skipped',
          date: @subscription.actionable_date
        )

        redirect_back(fallback_location: spree.admin_subscriptions_path, notice: notice)
      end

      private

      def model_class
        ::SolidusSubscriptions::Subscription
      end

      def location_after_save
        edit_object_url(@subscription)
      end

      def prepare_form
        @subscription.build_shipping_address(@subscription.shipping_address&.value_attributes)
        @subscription.build_billing_address(@subscription.billing_address&.value_attributes)
        @subscription.line_items.build
      end

      def load_payment_methods
        @payment_methods = Spree::PaymentMethod.active.available_to_admin.ordered_by_position
      end
    end
  end
end
