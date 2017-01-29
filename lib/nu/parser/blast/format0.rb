require 'nu/parser/blast/query'
require 'nu/parser/blast/sbjct'
require 'nu/parser/blast/hsp'

module Nu
  module Parser
    class Blast
      class Format0
        include Nu::Parser

        attr_accessor :queries, :blast_type

        # create a new Format0 parser
        def initialize(file)
          @query = nil
          @sbjct = nil
          @sbjct_number = 0
          @blast_type = nil
          @queries = []

          @file = file
        end

        # parse the input blast file
        def parse
          line = @file.readline
          @blast_type = line.split[0]
          buffer = parse_until(@file,/^Query=/) # get the 1st chunk of the blast report
          while buffer.length > 0
            if buffer[0] =~ /^Query=/
              process_buffer(buffer)
            end
            buffer = parse_until(@file,/^Query=/) 
          end # end while
        end # end parse

        # filter a blast query entry for important parts
        # @param [Array] buffer containing a "Query=" block from
        #   the blast output file
        # @return [Bool] success or failure of the processing
        def process_buffer(buffer)
          return false if buffer.length == 0
          extract_query(buffer)
          @queries << @query
        end # end process_buffer

        def extract_query(buffer)
          str = ""
          while line = buffer.shift
            break if line =~ /^\s*$/ # empty line, break
            str += line.chomp
          end
          str.gsub!(/\s+/, " ")
          @query = Query.new
          if str =~ /^Query= (.+?) (.*) ?\(([0-9,]+) letters\)/
            @query.query_id = $1
            @query.definition = $2
            @query.length = $3.gsub(",","").to_i
          else
            # Blast+ output has query id/definition and length on separate lines
            while line = buffer.shift
              str += line.chomp
              break if line =~ /Length=/
            end
            if str =~ /^Query=\s([^\s]+)\s?(.*)\s?Length=([,\d]+)/
              @query.query_id = $1
              @query.definition = $2
              @query.length = $3.gsub(",","").to_i
            end
          end
          extract_dbinfo(buffer)

          sbjct_buffer = Array.new
          while line = buffer.shift
            if line =~ /^>/ and sbjct_buffer.length > 0
              extract_sbjct(sbjct_buffer)
              sbjct_buffer.clear
              buffer.unshift(line)
            else
              sbjct_buffer << line
            end
          end
          extract_sbjct(sbjct_buffer) if sbjct_buffer.length > 0

        end # end extract_query
        
        def extract_dbinfo(buffer)
          str = ""
          while line = buffer.shift
            break if line =~ /^\s*$/ # empty line, break
            str += line.chomp
          end
          
          str.gsub!(/\s+/," ")
          if str =~ /Database:\s+(.+)\.?\s+([0-9,]+)\s+sequences;\s+([0-9,]+)\s+total\s+letters/
            db_name, db_seq_count, db_total_letters = $1, $2, $3
            @query.database = db_name
            @query.database_sequence_count = db_seq_count.gsub(",","").to_i
            @query.database_total_letters = db_total_letters.gsub(",","").to_i
          else
            $stderr.puts "extract_dbinfo: Database line mismatch!"
            $stderr.puts "database, database_sequence_count and database_total_letters are not set"
            $stderr.puts str
          end

          # eat up single-line summary cruft until beginning of subjects
          while line = buffer.shift
            if line =~ /^>/ # first sbjct, break
              buffer.unshift(line)
              break
            end
          end
        end

        def extract_sbjct(buffer)
          if buffer[0] !~ /^>/
            $stderr.puts "can't process subject buffer - missing fasta header line!"
            exit(1)
          end

          str = ""
          # read until blank line to get header, but ensure that we already have Length= line
          while line = buffer.shift
            break if line =~ /^\s*$/ && str =~ /Length\s*=/
            str += line.chomp
          end
          str.gsub!(/\s+/," ") # shrink spaces
          @sbjct = Sbjct.new
          if str =~ />(.+?)\s+(.*)\s*Length\s+=\s+(\d+)/m or
             str =~ />\s(.+?)\s+(.*)\s*Length=\s?(\d+)/m
            @sbjct.number = @query.sbjcts.length + 1
            @sbjct.sbjct_id = $1
            @sbjct.definition = $2.rstrip
            @sbjct.length = $3.to_i
            @sbjct.query = @query
          end
         
          hsp_buffer = Array.new
          while line = buffer.shift
            if line =~ /^>/ and hsp_buffer.length > 0
              extract_all_hsps(hsp_buffer)
              hsp_buffer.clear
              buffer.unshift(line)
              break
            else
              hsp_buffer << line
            end
          end
          extract_all_hsps(hsp_buffer) if hsp_buffer.length > 0
          
          @query.sbjcts << @sbjct
        end

        # create Hsp objects from the complete alignment section
        #
        # @param [Array] buffer containing all the lines from the
        #   alignment section
        def extract_all_hsps(buffer)
          unless buffer[0] =~ /^\s+Score =/
            $stderr.puts "can't process HSP buffer - missing Score = line!"
            exit(1)
          end

          hsp_buffer = Array.new
          while line = buffer.shift
            if line =~ /^\s+Score =/ and hsp_buffer.length > 0
              process_hsp(hsp_buffer)              
              hsp_buffer.clear
              buffer.unshift(line)
            else
              hsp_buffer << line
            end
          end
          process_hsp(hsp_buffer) if hsp_buffer.length > 0
        end

        def process_hsp(buffer)
          unless buffer[0] =~ /^\s+Score =/
            $stderr.puts "can't process HSP buffer - missing Score = line!"
            exit(1)
          end

          str = ""
          # read until blank line to get header
          while line = buffer.shift
            break if line =~ /^\s*$/
            str += line.chomp
          end

          hsp = Hsp.new
          if str =~ / Score =\s+(\d+(?:\.\d+)?)\s+bits\s+\((\d+)\)/
            hsp.bit_score = $1.to_f
            hsp.score = $2.to_i
          end

          if str =~ /Expect.*\s+=\s+(\d+\.\d+)/ or
             str =~ /Expect.*\s+=\s+(\d+e-\d+)/ or
             str =~ /Expect.*\s+=\s+(e-\d+)/
            hsp.evalue = $1.to_f 
          end

          if str =~ /Identities\s+=\s+(\d+)\/(\d+)\s+\((\d+%)\)/
            hsp.length = $2.to_i
            hsp.identity = $3.to_i
          end

          if str =~ /Positives\s+=\s+(\d+)\/(\d+)\s+\((\d+)%\)/
            hsp.positive = $1.to_i
          end

          if str =~ /Gaps\s+=\s+(\d+)\/(\d+)\s+\((\d+%)\)/
            hsp.gap_count = $1.to_i
          end

          if str =~ /Frame\s+=\s+([+-]\d)/
            hsp.query_frame = $1
          elsif str =~ /Frame\s+=\s+([+-]\d)\s+\/\s+([+-]\d)/
            hsp.query_frame = $1
            hsp.sbjct_frame = $2
          end
          
          if str =~ /Strand\s+=\s+(Plus|Minus)\s+\/\s+(Plus|Minus)/
            hsp.query_frame = $1 == "Plus" ? 1 : -1
            hsp.sbjct_frame = $2 == "Plus" ? 1 : -1
          end

          # read remaining buffer lines for the alignment
          # buffer.delete_if {|x| x =~ /^\s*$/} # drop empty lines

          query_to = nil
          sbjct_to = nil
          while buffer.length > 0
            line = buffer.shift
            if line =~ /Query/
              q_line = line
              m_line = buffer.shift
              s_line = buffer.shift
              leader = 0
             
              break if q_line =~ /#{@blast_type}/ # end of hsps so exit
              if q_line =~ /\s+Database:\s+#{@query.database}/ # end of report so exit
                break
              else
              end

              # process query line
              unless q_line =~ /^Query/
                $stderr.puts "Query line is malformed - skipping alignment"
                $stderr.puts q_line
                break
              end

              q_line =~ /^Query:?\s+(\d+)\s*(.+?)\s+(\d+)$/
              if hsp.query_from.nil?
                hsp.query_from = $1.to_i
              end
              hsp.query_sequence += $2
              query_to = $3.to_i

              if leader == 0
                q_line =~ /^(Query:?\s+\d+\s*)/
                leader = $1.length
              end
              
              # process mid line
              hsp.midline += m_line[leader,m_line.length]
              
              # process sbjct line
              unless s_line =~ /^Sbjct/
                $stderr.puts "Sbjct line is malformed - skipping alignment"
                $stderr.puts s_line
                break
              end

              s_line =~ /^Sbjct:?\s+(\d+)\s+(.+?)\s+(\d+)$/
              if hsp.sbjct_from.nil?
                hsp.sbjct_from = $1.to_i
              end
              hsp.sbjct_sequence += $2
              sbjct_to = $3.to_i
            end # end of if line =~ /Query/
          end # end while buffer.length > 0
          hsp.query_to = query_to
          hsp.sbjct_to = sbjct_to
          @sbjct.hsps << hsp # add this hsp to the sbjct
        end # end extract_hsp
      end # end of Nu::Parser::Blast::Format0 class
    end # end of Nu::Parser::Blast class
  end # end of Nu::Parser module
end # end of Nu module
