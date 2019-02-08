module Spree
  module Admin
    class SubscriptionsController < ResourceController
      skip_before_action :load_resource, only: :index
      before_action :gather_stats, only: :index

      def index
        @search = SolidusSubscriptions::Subscription.
                  accessible_by(current_ability, :index).ransack(params[:q])

        respond_to do |format|
          format.html do
            params[:q].permit! if params[:q].present?
            @subscriptions = @search.result(distinct: true).
                             includes(:line_items, :user).
                             joins(:line_items, :user).
                             page(params[:page]).
                             per(params[:per_page] || Spree::Config[:orders_per_page])
          end
          format.csv do
            send_data(SolidusSubscriptions::DownloadService.to_csv(search: @search), filename: "subscribers.csv")
          end
        end
      end

      def new
        @subscription.line_items.new
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

        redirect_to spree.admin_subscriptions_path, notice: notice
      end

      def activate
        @subscription.activate

        notice = if @subscription.errors.none?
                   I18n.t('spree.admin.subscriptions.successfully_activated')
                 else
                   @subscription.errors.full_messages.to_sentence
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

      def model_class
        ::SolidusSubscriptions::Subscription
      end

      def gather_stats
        this_month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
        today_range = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
        tomorrow_range = Time.zone.tomorrow.beginning_of_day..Time.zone.tomorrow.end_of_day
        active_subs = model_class.where.not(state: ['canceled', 'inactive'])

        @total_active_subs = active_subs.count
        @total_active_subs_this_month = active_subs.where(actionable_date: this_month_range).count
        @monthly_recurring_revenue = recurring_revenue(this_month_range)
        @todays_recurring_revenue = recurring_revenue(today_range)
        @tomorrows_recurring_revenue = recurring_revenue(tomorrow_range)
      end

      def recurring_revenue(range)
        subscriptions = model_class.actionable_between(range)
        subscriptions.reduce(0.0) do |total_revenue, subscription|
          total_revenue + subscription.total_revenue * recurrence_multiplier(subscription, range)
        end.to_f.round(2)
      end

      def recurrence_multiplier(subscription, range)
        multiplier = 1
        future_actionable_date = subscription.next_actionable_date

        return multiplier if range.first.is_a? ActiveSupport::TimeWithZone

        while range.include?(future_actionable_date)
          future_actionable_date += subscription.interval
          multiplier += 1
        end

        multiplier
      end
    end
  end
end
