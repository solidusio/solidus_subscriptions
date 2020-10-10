require 'webmock/rspec'
require 'vcr'

WebMock.disable_net_connect!

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
