#require 'nu/sequence'

module Nu
  class Sequence
    class Fasta < Sequence
      attr_accessor :header, :header_name, :header_description

      # create a new Nu::Sequence::Fasta object
      def initialize(options)
        super(options)
        options = {:header => nil}.merge! options
        @header = options[:header]
        temp = @header.split
        @header_name = temp.shift
        @header_description = temp.length > 0 ? temp.join(' ') : nil
      end

      # split sequence into columns
      def sequence_by_columns(cols = 60)
        seq = ''
        if length < cols
          seq << sequence
        else
          0.step(length, cols) { |segment| seq << sequence[segment, cols] << "\n" }
        end
        seq
      end

      # override to_s string representation
      def to_s(cols = 60)
        seq = ''
        if sequence =~ /\d+\s+\d+/
          # this is a fasta quality sequence
          scores = sequence.split(/\s+/)
          buffer = []
          while scores.length > 0
            score = scores.shift
            if buffer.length == 17
              seq << "#{buffer.join(' ')}\n"
              buffer.clear
              buffer << score
            else
              buffer << score
            end
          end
          seq << "#{buffer.join(' ')}\n" if buffer.length > 0
        else
          if cols == -1       # don't break the sequence up
            seq = sequence
          else
            seq = length < cols ? sequence : sequence_by_columns(cols)
          end
        end
        ">#{@header}\n#{seq}"
      end

      # find runs of N characters in the sequence and split
      def split_on_n(min_n = 10)
        count = 0
        sequence_chunks = []
        sequence.split(/[nN]{#{min_n},}/).each do |chunk|
          sequence_chunks << chunk
          count += 1
        end

        if count > 1
          outstr = ''
          sequence_chunks.each_with_index do |chunk, i|
            outstr << ">#{@header_name}_#{i + 1} #{@header_description}\n"
            outstr << "#{chunk}\n"
          end
          outstr
        else
          to_s
        end
      end
    end # end of Fasta class
  end # end of Sequence class
end # end of Nu module
