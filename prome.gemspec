# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prome/version'

Gem::Specification.new do |spec|
  spec.name          = "prome"
  spec.version       = Prome::VERSION
  spec.authors       = ["Zhou Rui"]
  spec.email         = ["zhourui@getqujing.com"]

  spec.summary       = %q{Prometheus integration for Rails.}
  spec.description   = %q{Prometheus integration for Rails.}
  spec.homepage      = "https://github.com/getqujing/prome"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "rails", "> 5.0.0"
  spec.add_dependency "prometheus-client", "~> 0.6.0"
end
