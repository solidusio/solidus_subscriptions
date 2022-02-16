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
  s.homepage = 'https://github.com/solidusio-contrib/solidus_subscriptions'

  if s.respond_to?(:metadata)
    s.metadata["homepage_uri"] = s.homepage if s.homepage
    s.metadata["source_code_uri"] = s.homepage if s.homepage
  end

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.test_files = Dir['spec/**/*']
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'deface'
  s.add_dependency 'i18n'
  s.add_dependency 'solidus', '2.10.5'
  s.add_dependency 'solidus_core', '2.10.5'
  s.add_dependency 'solidus_support', '~> 0.5'
  s.add_dependency 'state_machines'

  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'shoulda-matchers', '~> 3.1'
  s.add_development_dependency 'solidus_dev_support'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'versioncake'
  s.add_development_dependency 'yard'
end
