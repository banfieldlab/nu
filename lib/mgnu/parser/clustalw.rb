module MgNu
  module Parser
    # ClustalW is the class used for parsing clustalw multiple alignment output.
    class ClustalW
      attr_accessor :buffer, :raw
      attr_reader :file, :alignment

      # params [String] alignment file (*.aln)
      # params [Boolean] is this a file (default is true), or a string?
      # returns [MgNu::Alignment]
      def initialize(input = nil, file = true)
        if input
          if file
            if File.exists?(input) and File.readable?(input)
              @raw = File.read(input)
            end # end of exists and readable file checks
          else # file is false, so this must be a string with input
            @raw = input
          end
          @buffer = @raw.split(/\r?\n\r?\n/)
          @alignment = nil
          self.parse
          if @buffer.length == 0
            puts "ClustalW alignment file #{input} did not parse!"
            exit(1);
          end
        else
          error("MgNu::Parser::ClustalW.new(): need an existing file")
        end
      end

      # process the input multiple alignement
      def parse
        if @alignment == nil
          header = @buffer.shift
          @buffer[0].gsub!(/^(\r?\n)+/, '') # drop newline at start of section
          @buffer.collect! { |section| section.split(/\r?\n/) }
          
          match_lines = []
          # drop numbers if the alignment was run with "-SEQNOS=on"
          @buffer.each do |section|
              section.each { |line| line.sub!(/\s+\d+\s*$/, '') }
              match_lines << section.pop
          end

          # get the 1st position of a space from the right using
          # rindex.  Increment this by 1 to get the seq_start
          seq_start = (@buffer[0][0].rindex(/\s/) || -1) + 1

          # create ordered array of hashes with
          # seqname => sequence and create an array with a order of
          # sequences (seqname as value)
          order = Array.new
          h = Hash.new
          @buffer.each do |section|
            section.each do |line|
              name = line[0, seq_start].sub(/\s+\z/, '')
              sequence = line[seq_start..-1]
              if h.has_key?(name)
                h[name] += sequence
              else
                order << name
                h[name] = sequence
              end
            end
          end
        end
        @alignment = MgNu::Alignment.new(h, order)
      end # end of #parse method
    end # end of MgNu::Parser::ClustalW class
  end # end of MgNu::Parser module
end # end of MgNu module
