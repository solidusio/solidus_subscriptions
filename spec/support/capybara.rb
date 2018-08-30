require 'capybara/rspec'
require 'capybara-screenshot/rspec'

RSpec.configure do |config|

  Capybara.server_port = 8888 + ENV['TEST_ENV_NUMBER'].to_i
  Capybara.javascript_driver = :selenium
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end
end
