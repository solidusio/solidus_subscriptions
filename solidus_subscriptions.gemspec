# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_subscriptions/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_subscriptions'
  s.version     = SolidusSubscriptions::VERSION
  s.summary     = 'Add subscription support to Solidus'
  s.description = s.summary
  s.license     = 'BSD-3-Clause'

  s.author       = 'Solidus Team'
  s.email        = 'contact@solidus.io'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'deface'
  s.add_dependency 'i18n'
  s.add_dependency 'solidus'
  s.add_dependency 'solidus_support'
  s.add_dependency 'state_machines'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'relaxed-rubocop', '~> 2.4'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rspec-rails', '~> 4.0.0.beta2'
  s.add_development_dependency 'rubocop', '~> 0.75.1'
  s.add_development_dependency 'rubocop-rspec', '1.34.1'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'shoulda-matchers', '~> 3.1'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'versioncake'
  s.add_development_dependency 'yard'
end
