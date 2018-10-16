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

  spec.add_dependency('naught', '~> 0')
  spec.add_dependency('moneta', '~> 0')
  spec.add_dependency('tokyocabinet', '~> 0')
  spec.add_dependency('ox', '~> 0')
  spec.add_dependency('memoizable', '~> 0')
  spec.add_dependency('yard', '~> 0')
  spec.add_dependency('rake', '~> 0')
  spec.add_development_dependency('mime-types', '~> 0')
  spec.add_development_dependency('rspec', '~> 0')
  spec.add_development_dependency('rubocop', '~> 0')
  spec.add_development_dependency('timecop', '~> 0')
  spec.add_development_dependency('yardstick', '~> 0')
  spec.add_development_dependency('simplecov', '~> 0')
end
