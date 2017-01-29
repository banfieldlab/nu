module Nu
  module Parser
    class Blast
      class Hsp

        attr_accessor :number, :bit_score, :score, :evalue
        attr_accessor :query_from, :query_to, :sbjct_from, :sbjct_to
        attr_accessor :query_frame, :sbjct_frame, :identity, :positive
        attr_accessor :length, :query_sequence, :sbjct_sequence, :midline
        attr_accessor :gap_count, :mismatches, :sbjct, :query

        # create a new Hsp object
        def initialize
          @number = nil
          @bit_score = nil
          @score = nil
          @evalue = nil
          @query_from = nil
          @query_to = nil
          @sbjct_from = nil
          @sbjct_to = nil
          @query_frame = nil
          @sbjct_frame = nil
          @identity = nil
          @positive = nil
          @length = nil
          @query_sequence = ""
          @sbjct_sequence = ""
          @midline = ""
          @gap_count = nil
          @mismatches = nil
          @sbjct = nil
          @query = nil
        end

        def query_frameshifts
          if @query_sequence =~ /(?:\/|\\)/
            loc2frame = Hash.new
            re = /[\/\\]{1,2}/
            re.global_match(@query_sequence.gsub(/[- ]/,'')) do |m|
              frame = nil
              # m.begin(0) is location of char match
              # (m.begin(0) - 1) * 3 is the length of the coding dna
              #    up to the (but not including) the char match
              # (m.begin(0) - 1) * 3 + @query_from - 1 is the corrected
              #   position taking into account the start of the query
              #   sequence.  query_from is reported in nt
              if @query_from > @query_to
                location = @query_from - (m.begin(0) * 3 - 1)
              else
                location = (m.begin(0) * 3 - 1) + @query_from
              end
              case m[0]
              when '/'
                frame = 1
              when '//'
                frame = 2
              when '\\'
                frame = -1
              when '\\\\'
                frame = -2
              end
              loc2frame[location] = frame
            end # end re.global_match
            return loc2frame
          else
            return nil
          end # end if @query_sequence =~ /(?:\/|\\)/
        end # end query_frameshifts

      end # end of Nu::Parser::Blast::Hsp class
    end # end of Nu::Parser::Blast class

  end # end of Nu::Parser module
end # end of Nu module
