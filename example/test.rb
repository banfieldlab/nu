$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'nu'
require 'fileutils'
require 'benchmark'

DB="uniref90_010913.fasta"

# CREATE
#db = nil
#puts Benchmark.measure {
#  db = Nu::Parser::FastaHeaderIndex2.new(DB)
#}
#db.close
#db = nil
#puts Benchmark.measure {
#  db = Nu::Parser::FastaHeaderIndex.new(DB)
#}
#db.close
#$stderr.puts 'done creating db'
#__END__

# ACCESS
#db = Nu::Parser::FastaHeaderIndex.new(DB)
db = Nu::Parser::FastaHeaderIndex2.new(DB)
$stderr.puts 'done opening db'

names = []
File.open('header_names.txt').each do |name|
  name.chomp!
  names << name
end
total = names.length
$stderr.puts "read in names (#{total})"

srand 12345

Benchmark.bm do |x|
  3.times do
    set = []
    100_000.times do |n|
      set << names[rand(total)]
    end
    x.report {
      set.each do |name|
        db[name]
      end
    }
  end
end
