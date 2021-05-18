# frozen_string_literal: true

namespace :solidus_subscriptions do
  desc 'Create orders for actionable subscriptions'
  task process: :environment do
    SolidusSubscriptions::Processor.run
  end

  desc 'Send reminders for subscriptions soon to be renewed'
  task send_reminder: :environment do
    SolidusSubscriptions::Reminder.run
  end

end
