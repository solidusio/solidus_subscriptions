source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'v2.7')
gem 'solidus', github: 'solidusio/solidus', branch: branch
# Provides basic authentication functionality for testing parts of your engine
gem 'solidus_auth_devise', '~> 1.0'
gem 'rails', '< 5.2.2'

if branch != 'master' && branch < 'v2.0'
  gem "rails_test_params_backport", group: :test
end

gem 'pg', '~> 0.21'
gem 'mysql2'
gem 'listen'

group :test do
  gem 'rails-controller-testing'
  gem 'timecop'
end

gemspec
