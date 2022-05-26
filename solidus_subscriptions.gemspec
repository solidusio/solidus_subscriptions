# frozen_string_literal: true

require_relative 'lib/solidus_subscriptions/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_subscriptions'
  spec.version = SolidusSubscriptions::VERSION
  spec.authors = ['Solidus Team']
  spec.email = 'contact@solidus.io'

  spec.summary = 'Add subscription support to Solidus'
  spec.description = 'Add subscription support to Solidus'
  spec.homepage = 'https://github.com/solidusio-contrib/solidus_subscriptions'
  spec.license = 'BSD-3-Clause'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/solidusio-contrib/solidus_subscriptions'
  spec.metadata['changelog_uri'] = 'https://github.com/solidusio-contrib/solidus_subscriptions/blob/master/CHANGELOG.md'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'deface'
  spec.add_dependency 'httparty', '~> 0.18'
  spec.add_dependency 'i18n'
  spec.add_dependency 'solidus_core', '>= 2.0.0', '< 4'
  spec.add_dependency 'solidus_support', '~> 0.9'
  spec.add_dependency 'state_machines'

  spec.add_development_dependency 'rspec-activemodel-mocks'
  spec.add_development_dependency 'shoulda-matchers', '~> 4.4'
  spec.add_development_dependency 'solidus_dev_support', '~> 2.0'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'versioncake'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
end
