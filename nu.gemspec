# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nu/version'

Gem::Specification.new do |spec|
  spec.name          = "nu"
  spec.version       = Nu::Version
  spec.authors       = ["Brian C. Thomas"]
  spec.email         = ["bct.x42@gmail.com"]
  spec.summary       = %q{Nu Ruby Bioinformatics Library}
  spec.description   = %q{Lightweight ruby bioinformatics library}
  spec.homepage      = "http://www.metagenomi.co"
  spec.license       = "MIT"

  # spec.files         = `git ls-files -z`.split("\x0")
  spec.files = %w(.yardopts README.md Rakefile nu.gemspec)
  spec.files += Dir.glob('lib/**/*.rb')
  spec.files += Dir.glob('spec/**/*')


  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('naught')
  spec.add_dependency('moneta')
  spec.add_dependency('tokyocabinet')
  spec.add_dependency('ox')
  spec.add_dependency('memoizable')
  spec.add_dependency('yard')
  spec.add_dependency('rake')
  spec.add_development_dependency('mime-types')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('timecop')
  spec.add_development_dependency('yardstick')
  spec.add_development_dependency('simplecov')
end
