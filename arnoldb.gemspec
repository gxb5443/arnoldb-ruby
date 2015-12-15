# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arnoldb/version'

Gem::Specification.new do |spec|
  spec.name          = "arnoldb"
  spec.version       = Arnoldb::VERSION
  spec.authors       = ["Jim Walker"]
  spec.email         = ["jim.walker@namely.com"]
  spec.summary       = %q{Ruby connection for Arnoldb Services}
  spec.description   = %q{This is a lightweight gem solution which enables integration with Arnoldb and ruby applications}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize"
  spec.add_dependency "grpc", "~> 0.11"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "redis", "~> 3.2"
  spec.add_development_dependency "rspec"
end
