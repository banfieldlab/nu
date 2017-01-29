module Nu
  module Parser
    class Fasta
      include Enumerable

      attr_reader :file, :filename

      # create a new Fasta parser
      def initialize(filename = nil, quality_file = false)
        @quality_file = quality_file
        @filename = filename
        if filename
          if File.exists?(filename) and File.readable?(filename)
            @file = File.open(filename)
          else
            raise "\n\n -- No file by that name (#{filename}).  Exiting\n\n"
            exit(1)
            #@file = File.new(filename, "w")
          end
        else
          error("Nu::Parser::Fasta.new(): need a filename or an existing file")
        end
      end

      # override enumerables
      def each
        @buffer = [] # temp storage
        @file.each_line do |line|
          line.chomp!
          if line =~ />(.*)/  # got a header line
            if @buffer.length > 0
              if @quality_file
                yield Nu::Sequence::Fasta.new(:header => @buffer.shift,
                                                  :sequence => @buffer.join(" "))
              else
                yield Nu::Sequence::Fasta.new(:header => @buffer.shift,
                                                  :sequence => @buffer.join(""))
              end
            end
            @buffer = []
            @buffer << $1
          else  # got a sequence line
            @buffer << line
          end
        end # end of file io
        @file.close

        # don't forget to yield the last one
        if @buffer.length > 0
          if @quality_file
            yield Nu::Sequence::Fasta.new(:header   => @buffer.shift,
                                              :sequence => @buffer.join(" "))
          else
            yield Nu::Sequence::Fasta.new(:header   => @buffer.shift,
                                              :sequence => @buffer.join(""))
          end
        end
      end # end of #each
    end # end of Nu::Parser::Fasta class
  end # end of Nu::File module
end # end of Nu module
