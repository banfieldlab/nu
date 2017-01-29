require 'nu/parser/iprscan/hit'

module Nu
  module Parser
    class IprscanFile
      attr_reader :file, :queries

      include Nu::Loggable

      def initialize(filename = nil)
        if filename
          if File.exists?(filename) and File.readable?(filename)
            @file = File.open(filename)
          else
            error("Nu::Parser::IprscanFile.new(): problems with filename")
            raise "File doesn't exist or is not readable!"
          end
        else
          error("Nu::Parser::IprscanFile.new(): need a filename")
          raise "no filename given!"
        end

        @queries = Hash.new

        parse
      end

      def parse
        @file.each do |line|
          line.chomp!
          hit = Nu::Parser::Iprscan::Hit.new(line)
          @queries.has_key?(hit.query) ? @queries[hit.query] << hit : @queries[hit.query] = [ hit ]
        end
      end
    end # end of Nu::Parser::IprscanFile class
  end # end of Nu::Parser module
end # end of Nu module

__END__
