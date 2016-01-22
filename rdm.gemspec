lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rdm/version'

Gem::Specification.new do |spec|
  spec.name          = "rdm"
  spec.version       = Rdm::VERSION
  spec.authors       = ["Droid Labs"]
  spec.description   = %q{Ruby Dependency Manager}
  spec.summary       = %q{Ruby Dependency Manager}

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency "activesupport"
end