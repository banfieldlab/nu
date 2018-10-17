require 'mgnu/parser/iprscan/hit'

module MgNu
  module Parser
    class IprscanFile
      attr_reader :file, :queries

      include MgNu::Loggable

      def initialize(filename = nil)
        if filename
          if File.exists?(filename) and File.readable?(filename)
            @file = File.open(filename)
          else
            error("MgNu::Parser::IprscanFile.new(): problems with filename")
            raise "File doesn't exist or is not readable!"
          end
        else
          error("MgNu::Parser::IprscanFile.new(): need a filename")
          raise "no filename given!"
        end

        @queries = Hash.new

        parse
      end

      def parse
        @file.each do |line|
          line.chomp!
          hit = MgNu::Parser::Iprscan::Hit.new(line)
          @queries.has_key?(hit.query) ? @queries[hit.query] << hit : @queries[hit.query] = [ hit ]
        end
      end
    end # end of MgNu::Parser::IprscanFile class
  end # end of MgNu::Parser module
end # end of MgNu module

__END__
