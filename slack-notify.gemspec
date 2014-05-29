# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack-notify/version'

Gem::Specification.new do |spec|
  spec.name          = "slack-notify"
  spec.version       = SlackNotify::VERSION
  spec.authors       = ["Dan Sosedoff"]
  spec.email         = ["dan.sosedoff@gmail.com"]
  spec.description   = %q{Send notifications to a Slack channel}
  spec.summary       = %q{Send notifications to a Slack channel}
  spec.homepage      = "https://github.com/sosedoff/slack-notify"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",   "~> 1.3"
  spec.add_development_dependency "rake",      "~> 10"
  spec.add_development_dependency "simplecov", "~> 0.7"
  spec.add_development_dependency "rspec",     "~> 2.13"
  spec.add_development_dependency "webmock",   "~> 1.0"

  spec.add_dependency "faraday", "~> 0.9.0"
  spec.add_dependency "json",    "~> 1.8"
end
