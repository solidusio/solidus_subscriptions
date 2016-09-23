namespace :solidus_subscriptions do
  desc 'Create orders for actionable subscriptions'
  task process: :environment do
    SoliudusSubscriptions::Processor.run
  end
end
