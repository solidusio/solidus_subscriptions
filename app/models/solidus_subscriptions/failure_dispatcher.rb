# A handler for behaviour that should happen after installments are marked as
# failures
module SolidusSubscriptions
  class FailureDispatcher < Dispatcher
    def dispatch
      order.touch :completed_at
      order.cancel!
      order.completed_at = nil
      order.save
      installments.each { |i| i.failed!(order) }
      super
    end

    def message
      "
      Something went wrong processing installments: #{installments.map(&:id).join(', ')}.
      They have been marked for reprocessing.
      "
    end
  end
end
