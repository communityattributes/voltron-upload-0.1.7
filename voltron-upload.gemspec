# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'voltron/upload/version'

Gem::Specification.new do |spec|
  spec.name          = "voltron-upload"
  spec.version       = Voltron::Upload::VERSION
  spec.authors       = ["Eric Hainer"]
  spec.email         = ["eric@commercekitchen.com"]

  spec.summary       = %q{Adds logic to handle drag and drop file uploads with Dropzone.js}
  spec.homepage      = "https://github.com/ehainer/voltron-upload"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4.2"
  spec.add_dependency "voltron", ">= 0.2.0"
  spec.add_dependency "carrierwave", ">= 1.0.0.beta"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "rspec-rails", ">= 3.4"
  spec.add_development_dependency "pg", ">= 0.19.0"
  spec.add_development_dependency "simplecov", "0.11.0"
  spec.add_development_dependency "jquery-rails", "~> 4.2.0"
end
