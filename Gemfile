# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'main')
gem 'solidus', github: 'solidusio/solidus', branch: branch

# The solidus_frontend gem has been pulled out since v3.2
gem 'solidus_frontend', github: 'solidusio/solidus_frontend'

rails_requirement_string = ENV.fetch('RAILS_VERSION', '~> 7.0')
gem 'rails', rails_requirement_string

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  rails_version = Gem::Requirement.new(rails_requirement_string).requirements[0][1]
  sqlite_version = rails_version < Gem::Version.new(7.2) ? "~> 1.4" : "~> 2.0"

  gem 'sqlite3', sqlite_version
end

gemspec

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3')
  # Fix for Rails 7+ / Ruby 3+, see https://stackoverflow.com/a/72474475
  gem 'net-imap', require: false
  gem 'net-pop', require: false
  gem 'net-smtp', require: false
end

# Use a local Gemfile to include development dependencies that might not be
# relevant for the project or for other contributors, e.g. pry-byebug.
#
# We use `send` instead of calling `eval_gemfile` to work around an issue with
# how Dependabot parses projects: https://github.com/dependabot/dependabot-core/issues/1658.
send(:eval_gemfile, 'Gemfile-local') if File.exist? 'Gemfile-local'
