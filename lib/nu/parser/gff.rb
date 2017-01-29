module Nu
  module Parser
    class GFF
      include Enumerable

      attr_reader :file

      # create a new GFF parser
      def initialize(filename = nil)
        if filename
          if File.exists?(filename) and File.readable?(filename)
            @file = File.open(filename)
          else
            @file = File.new(filename, "w")
          end
        else
          error("Nu::Parser::GFF.new(): need a filename for an existing file")
        end
      end

      # override enumerables
      def each
        @file.each_line do |line|
          line.chomp!
          next if line =~ /^#/
          yield Record.new(line)
        end
      end # end of #each

      # class to deal with each line (record) of data
      class Record
        attr_accessor :name, :source, :feature, :start, :end
        attr_accessor :score, :strand, :frame, :attributes

        def initialize(line)
          @name, @source, @feature, @start, @end,
            @score, @strand, @frame, @attributes = line.split("\t")
          @attributes = parse_attributes(attributes) if attributes
        end
        
        alias :seqname :name

        private

        def parse_attributes(attributes)
          hash = Hash.new
          attributes.split(/[^\\];/).each do |atr|
            key, value = atr.split(' ', 2)
            hash[key] = value
          end
          hash
        end
      end # end of Nu::Parser::GFF::Record class
    end # end of Nu::Parser::GFF class
  end # end of Nu::Parser module
end # end of Nu module
