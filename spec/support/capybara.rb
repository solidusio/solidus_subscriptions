require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'chromedriver-helper'

RSpec.configure do |_config|
  Capybara.server_port = 8888 + ENV['TEST_ENV_NUMBER'].to_i
  Capybara.javascript_driver = :selenium
  Capybara.register_driver :selenium do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %w[ headless disable-gpu ]
      }
    )
    Capybara::Selenium::Driver.new(app,
                                   browser: :chrome,
                                   desired_capabilities: capabilities
                                  )
  end
end
