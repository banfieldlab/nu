# require 'xml/libxml'
require 'nu/loggable'
require 'ox'

module Nu
  module Parser
    class Blast
      require_relative 'blast/format7'
      require_relative 'blast/format8'
      require_relative 'blast/format0'

      include Loggable
      include Enumerable

      attr_accessor :format, :input

      # create a new blast parser
      def initialize(input = nil, format = nil)
        if input
          if File.exists?(input) and File.readable?(input)
            @file = File.open(input)
            @input_type = File
          elsif input.class == String
            # assume a string containing the blast report
            @input_type = String
          else
            raise "\n\n -- No file by that name (#{input}).  Exiting\n\n"
            exit(1)
          end
        else
          error("Nu::Parser::Blast.new(): needs a filename or atring of Blast data")
          exit(1)
        end
        
        @input = input
        @format = format

        # don't overwrite a format if given one
        if @format.nil?
          @format = 7 if @input =~ /.*\.xml/ and @input_type == File
          @format = 8 if @input =~ /.*8$/ and @input_type == File
        end
       
        if @format.nil?
          error("Please set the format type!");
          exit(1)
        end

        case @format
        when 7
          #XML::SaxParser.file(@input)
          if @input_type == File
            @parser = Format7.new()
          else
            # string input?
          end
        when 8
          if @input_type == File
            @parser = Format8.new(@file)
          elsif @input_type == String
            @parser = Format8.new(@input)
          end
        when 0
          if @input_type == File
            @parser = Format0.new(@file)
          elsif @input_type == String
            @parser = Format0.new(@input)
          end
        end
      end # end initialize

      def parse
        if @format == 7
          Ox.sax_parse(@parser, @file)
        else
          @parser.parse
        end
        return(@parser.queries)
      end

      def each(&b)
        @parser.each(&b)
      end
    end # end of Nu::Parser::Blast class

  end # end of Nu::File module
end # end of Nu module
