# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
solidus_git, solidus_frontend_git = if (branch == 'master') || (branch >= 'v3.2')
                                      %w[solidusio/solidus solidusio/solidus_frontend]
                                    else
                                      %w[solidusio/solidus] * 2
                                    end

gem "solidus", github: solidus_git, branch: branch
gem "solidus_core", github: solidus_git, branch: branch
gem "solidus_backend", github: solidus_git, branch: branch
gem "solidus_api", github: solidus_git, branch: branch
gem "solidus_sample", github: solidus_git, branch: branch
gem 'solidus_frontend', github: solidus_frontend_git, branch: branch

# Needed to help Bundler figure out how to resolve dependencies,
# otherwise it takes forever to resolve them.
# See https://github.com/bundler/bundler/issues/6677
gem 'rails', '>0.a'

# Provides basic authentication functionality for testing parts of your engine
gem 'solidus_auth_devise'

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  gem 'sqlite3'
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
