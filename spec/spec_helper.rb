$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'timecop'

require 'nu'

# set up configure for RSpec
RSpec.configure do |config|
  # config.before { Nu::XXXXXX.reset_configuration }
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# base fixture path
#
# @return [String] load path for fixtures
def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

# return json given a fixture file name
#
# @param [String] file name
# @return [Hash] json hash
def fixture(file)
  File.read(fixture_path + '/' + file)
end

# return multiple fixtures given multiple file names
#
# @param [Array] file names
# @return [Array] array of json hashes
def fixtures(files)
  all = []
  files.each do |file|
    all << Yajl::Parser.parse(File.read(fixture_path + '/' + file))
  end
  Yajl::Encoder.encode(all)
end

# return a group of fixtures repeated count times
#
# @param [String,Fixnum] file name and integer count
# @return [Array] array of json hashes
def fixture_set(file, count)
  all = []
  content = Yajl::Parser.parse(fixture(file))
  (1 .. count).each do
    all << content
  end
  Yajl::Encoder.encode(all)
end
