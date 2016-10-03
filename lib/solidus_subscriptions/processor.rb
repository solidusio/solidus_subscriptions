# This class is responsible for finding subscriptions and installments
# which need to be processed. It will group them together by user and attempts
# to process them together.
#
# This class passes the reponsibility of actually creating the order off onto
# the consolidated installment class.
#
# This class generates `ProcessInstallmentsJob`s
module SolidusSubscriptions
  class Processor
    class << self
      # Find all actionable subscriptions and intallments, group them together
      # by user, and schedule a processing job for the group as a batch
      def run
        batched_users_to_be_processed.each { |batch| new(batch).build_jobs }
      end

      private

      def batched_users_to_be_processed
        subscriptions = SolidusSubscriptions::Subscription.arel_table
        installments = SolidusSubscriptions::Installment.arel_table

        Spree::User.
          joins(:subscriptions).
          joins(
            subscriptions.
              join(installments, Arel::Nodes::OuterJoin).
              on(subscriptions[:id].eq(installments[:subscription_id])).
              join_sources
          ).
          where(
            SolidusSubscriptions::Subscription.actionable.arel.constraints.reduce(:and).
              or(SolidusSubscriptions::Installment.actionable.arel.constraints.reduce(:and))
          ).
          distinct.
          find_in_batches
      end
    end

    # @return [Array<Spree.user_class>]
    attr_reader :users

    # Get a new instance of the SolidusSubscriptions::Processor
    #
    # @param users [Array<Spree.user_class>] A list of users with actionable
    #   subscriptions or installments
    #
    # @return [SolidusSubscriptions::Processor]
    def initialize(users)
      @users = users
      @installments = {}
    end

    # Create `ProcessInstallmentsJob`s for the users used to initalize the
    # instance
    def build_jobs
      users.map { |user| ProcessInstallmentsJob.perform_later installments(user) }
    end

    private

    def subscriptions_by_id
      @subscriptions_by_id ||= Subscription.
        actionable.
        where(user_id: user_ids).
        group_by(&:user_id)
    end

    def retry_installments
      @failed_installments ||= Installment.
        actionable.
        includes(:subscription).
        where(solidus_subscriptions_subscriptions: { user_id: user_ids }).
        group_by { |i| i.subscription.user_id }
    end

    def installments(user)
      @installments[user.id] ||= retry_installments.fetch(user.id, []) + new_installments(user)
    end

    def new_installments(user)
      subscriptions_by_id.fetch(user.id, []).map { |sub| sub.installments.create! }
    end

    def user_ids
      @user_ids ||= users.map(&:id)
    end
  end
end
