# frozen_string_literal: true

namespace :solidus_subscriptions do
  desc 'Create orders for actionable subscriptions'
  task process: :environment do
    SolidusSubscriptions::Processor.run
  end
end
