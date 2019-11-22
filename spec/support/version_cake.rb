RSpec.configure do |config|
  if defined?(VersionCake::TestHelpers)
    config.include VersionCake::TestHelpers, type: :controller
    config.before(:each, type: :controller) do
      set_request_version('', 1)
    end
  end
end
