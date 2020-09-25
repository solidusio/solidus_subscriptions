# frozen_string_literal: true

# This error should be raised if a user attempts to subscribe to a item which
# is not subscribable
module SolidusSubscriptions
  class UnsubscribableError < StandardError
    def initialize(subscribable)
      @subscribable = subscribable
      super
    end

    def to_s
      <<-MSG.squish
        #{@subscribable.class} with id: #{@subscribable.id} cannot be
        subscribed to.
      MSG
    end
  end
end
