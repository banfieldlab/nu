module Nu
  module Parser
    class Pilercr
      include Enumerable

      attr_reader :file, :filename

      # create a new Pilercr parser
      def initialize(filename = nil)
        @filename = filename
        if filename
          if File.exists?(filename) and File.readable?(filename)
            @file = File.open(filename)
          else
            raise "\n\n -- No file by that name (#{filename}).  Exiting\n\n"
            exit(1)
          end
        else
          $stderr.puts "Nu::Parser::Pilercr.new(): need a filename or an existing file"
          exit(1)
        end
      end

      # override enumerables
      def each
        # read by blocks, starting with "Array " lines
        array_count = 0
        processed = 0
        @file.each_line("Array ") do |block|
          if array_count == processed and array_count > 0 # processed all the blocks in this file
            break
          else
            if block =~ /^pilercr/
              if block =~ /(\d+) putative/
                array_count= $1.to_i
              end
              next
            else
              yield process_buffer(block.split(/\n/))
              processed += 1
            end
          end
        end
      end # end of File#each

      def process_buffer(buffer)
        pilercr = Nu::Pilercr.new
        buffer.each do |line|
          if line =~ /SUMMARY/
            buffer.clear
            next
          end
          next if line =~ /^\s*$/
          next if line =~ /^\d+$/
          next if line =~ /^\s+Pos/
          next if line =~ /^Array\s*$/
          next if line =~ /^=+/
          if line =~ />(.+)/
            temp = $1.split(/\s+/)
            if temp.length > 1
              pilercr.header_name = temp.shift
              pilercr.header = temp.join(" ")
            else
              pilercr.header_name = temp[0]
              pilercr.header = temp[0]
            end
          else
            temp = line.split(/\s+/)
            temp.shift # drop empty space
            if temp.length == 4        # final line with repeat sequence
              pilercr.total_repeats = temp[0].to_i
              pilercr.repeat_length = temp[1].to_i
              pilercr.total_spacers = temp[2].to_i
              pilercr.repeat_sequence = temp[3]
            elsif temp.length == 6     # line with unknown spacer length
              pilercr.repeats << Nu::Pilercr::Repeat.new(:position      => temp[0].to_i,
                                                            :length        => temp[1].to_i,
                                                            :identity      => temp[2].to_f,
                                                            :spacer_length => temp[3].to_i,
                                                            :match_line    => temp[4],
                                                            :spacer        => temp[5])
            elsif temp.length == 7     # normal repeat line
              pilercr.repeats << Nu::Pilercr::Repeat.new(:position      => temp[0].to_i,
                                                            :length        => temp[1].to_i,
                                                            :identity      => temp[2].to_f,
                                                            :spacer_length => temp[3].to_i,
                                                            :left_flank    => temp[4],
                                                            :match_line    => temp[5],
                                                            :spacer        => temp[6])

            else
              $stderr.puts "WARN: Unknown line format"
              $stderr.puts line
            end
          end # end if/else
        end # end buffer.each do |line|
        pilercr
      end # end process_buffer method

    end # end of Nu::Parser::Pilercr class
  end # end of Nu::Parser module
end # end of Nu module
