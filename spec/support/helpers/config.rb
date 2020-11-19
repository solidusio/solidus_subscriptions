module SolidusSubscriptions
  module TestingSupport
    module ConfigHelper
      def stub_config(options)
        allow(SolidusSubscriptions.configuration).to receive_messages(options)
      end
    end
  end
end

RSpec.configure do |config|
  config.include SolidusSubscriptions::TestingSupport::ConfigHelper
end
