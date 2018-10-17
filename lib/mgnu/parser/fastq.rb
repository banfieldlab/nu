module MgNu
  module Parser
    class Fastq
      include Enumerable
      attr_reader :file, :filename

      # create a new Fastq parser
      def initialize(filename = nil)
        @filename = filename
        if @filename
          if File.exists?(@filename) and File.readable?(@filename)
            @file = File.open(@filename)
          else
            raise "\n\n -- No file by that name (#{@filename}).  Exiting\n\n"
            exit(1)
          end
        else
          $stderr.puts("MgNu::Parser::Fastq.new(): need an existing fastq file name")
          exit(1)
        end
      end

      # override enumerables
      def each
        while @file.eof != true # keep reading until EOF
          header = @file.readline.chomp
          sequence = @file.readline.chomp
          qualhdr = @file.readline.chomp
          quality = @file.readline.chomp
          if header =~ /^@(.*)/
            header = $1
            if qualhdr =~ /^\+(.*)/
              qualhdr = $1
            else
              error("Malformed quality header!")
              error("\n#{qualhdr}")
              error("\nExiting at line #{@file.lineno}")
              exit(1)
            end
            if header != qualhdr
              if qualhdr =~ /\s*/
                qualhdr = header
              else
                warn("Sequence header and quality header don't match!")
                warn("sequence: #{header}")
                warn(" quality: #{qualhdr}")
              end
            end
            yield MgNu::Sequence::Fastq.new(:header => header, :sequence => sequence, :qualhdr => qualhdr, :quality => quality)
          else
            $stderr.puts "Malformed header!"
            $stderr.puts "\n#{header}"
            $stderr.puts "\nExiting at line #{@file.lineno}"
            exit(1)
          end
        end # end of while @file.eof
      end # end of #each

    end # end of MgNu::Parser::Fasta class
  end # end of MgNu::File module
end # end of MgNu module
