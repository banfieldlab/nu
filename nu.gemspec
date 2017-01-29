# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nu/version'

Gem::Specification.new do |spec|
  spec.name          = "nu"
  spec.version       = Nu::Version
  spec.authors       = ["Brian C. Thomas"]
  spec.email         = ["bcthomas@berkeley.edu"]
  spec.summary       = %q{Nu Ruby Bioinformatics Library}
  spec.description   = %q{Lightweight ruby bioinformatics library}
  spec.homepage      = "http://ggkbase.berkeley.edu"
  spec.license       = "MIT"

  # spec.files         = `git ls-files -z`.split("\x0")
  spec.files = %w(.yardopts README.md Rakefile nu.gemspec)
  spec.files += Dir.glob('lib/**/*.rb')
  spec.files += Dir.glob('spec/**/*')


  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
