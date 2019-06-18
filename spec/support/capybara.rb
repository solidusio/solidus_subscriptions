require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'webdrivers'
Webdrivers::Chromedriver.update

RSpec.configure do |config|
  config.include Rack::Test::Methods, type: :requests

  Capybara.server_port = 8888 + ENV['TEST_ENV_NUMBER'].to_i

  Capybara.javascript_driver = :selenium
  Capybara.register_driver :selenium do |app|
    driver_options = Selenium::WebDriver::Chrome::Options.new(
      args: %w[ headless disable-gpu window-size=1280,1024 ]
    )

    Capybara::Selenium::Driver.new(
			app,
			browser: :chrome,
      options: driver_options
		)
	end
end
