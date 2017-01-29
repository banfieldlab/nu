require 'nu/parser/sam/header'
require 'nu/parser/sam/alignment'

module Nu
  module Parser
    class Sam
      include Enumerable
      include Nu::Loggable
      include Nu::Parser

      FIELDS = [:name, :flag, :hit, :position, :quality, :cigar, :mate_ref,
                :mate_pos, :distance, :sequence, :query_qual, :other]

      attr_reader :file, :header #, :alignments

      # create a new SAM file parser
      def initialize(filename = nil)
        @header = nil
        if filename
          if File.exists?(filename) and File.readable?(filename)
            # # find all the reference sequences
            # # skip header lines (^@) and then only save the 3rd column
            # # from the sam file input, only return unique names, then
            # # split on newlines
            # `egrep -v '^@' #{filename} | cut -f3 | uniq`.split(/\n/).each do |ref|
            #   if @references.has_key?(ref)
            #     $stderr.puts "Already a reference by name (#{ref})"
            #     $stderr.puts "... skipping"
            #   else
            #     @references[ref] = Nu::Parser::Sam::Reference.new(:name => ref)
            #   end
            # end
            
            @file = File.open(filename)
          end # end of exists and readable file checks
        else
          error "Nu::Parser::Sam.new(): need a SAM file"
          exit(1)
        end # end of if/else filename
      end

      # override enumerables
      # Nu::Parser::Sam will emit a reference-object with every
      # iteration.  Iteration happens with file-reading.
      def each
        header_buffer = Array.new
        # short-term buffer hash
        alignment_buffer = Hash.new
        
        @file.each do |line|
          next if line =~ /^\s*$/
          line.chomp!
          if line =~ /^@/
            header_buffer << line
          else
            if header_buffer.length > 0
              @header = process_header(header_buffer)
              header_buffer.clear
            end
            alignment_attrs = Hash[*FIELDS.zip(line.split("\t"))]
            # TODO last field needs to be globbed into array
            alignment = Nu::Parser::Sam::Alignment.new(alignment_attrs)
            next unless alignment.matched_and_paired?
            key = alignment.first_read? ? :first : :second
            if !alignment_buffer[alignment.basename]
              alignment_buffer[alignment.basename] = { key => alignment }
            else
              read_pair = alignment_buffer[alignment.basename] 
              read_pair[key] = alignment
              yield Nu::Parser::Sam::Pair.new(name, read_pair[:first], read_pair[:second])
              alignment_buffer.delete(alignment.basename)
            end
          end
        end
      end

      def process_header(buffer)
        hdr = Nu::Parser::Sam::Header.new
        buffer.each do |line|
          case line
          when /^@HD/
            if line =~ /VN:(.+)[\s\n]/
              hdr.vn = $1
            end
            if line =~ /SO:(.+)[\s\n]/
              hdr.so = $1
            end
          when /^@SQ/
            ref = nil
            if line =~ /SN:(.+)[\s\n]/
              # verify this ref is in the @references hash (from
              # initialize()
              if @references.has_key?($1)
                ref = @references[$1]
              else
                $stderr.puts "WARNING: reference from header not found in alignments"
                # create a ref
                ref = Nu::Parser::Sam::Reference.new(:name => $1)
                @references[$1] = ref
              end
            end

            if line =~ /LN:(\d+)[\s\n]/
              if ref
                ref.ln = $1.to_i
              end
            end
          end
        end
        return hdr
      end # end process_header_line
    end # end of Nu::Parser::Sam class
  end # end of Nu::Parser module
end # end of Nu module
__END__
