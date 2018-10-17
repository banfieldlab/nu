# require 'xml/libxml'
require 'ox'
require 'mgnu/parser/blast/query'
require 'mgnu/parser/blast/sbjct'
require 'mgnu/parser/blast/hsp'

module MgNu
  module Parser
    class Blast
      class Format7 < ::Ox::Sax

        attr_accessor :queries

        # create a new Format7 parser
        def initialize()
          @query = nil
          @sbjct = nil
          @hsp = nil
          @current_element = nil
          @queries = []
        end

        def start_element(element)
          # set the current element - used during character parsing
          @current_element = element

          case element
          when :Iteration
            # start a new Query
            @query = Query.new if @query.nil?
          when :Hit
            # start a new Sbjct
            @sbjct = Sbjct.new if @sbjct.nil?
            @sbjct.query = @query
          when :Hsp
            # start a new Hsp
            @hsp = Hsp.new if @hsp.nil?
            @hsp.sbjct = @sbjct
            @hsp.query = @query
          end
        end

        def text(characters = '')
          return if characters =~ /^\s+$/
          case @current_element
          when :"Iteration_iter-num"
            @query.number = characters.to_i
          when :"Iteration_query-ID"
            @query.query_id += characters
          when :"Iteration_query-def"
            @query.definition += characters
          when :"Iteration_query-len"
            @query.length = characters.to_i

          when :Hit_num
            @sbjct.number = characters.to_i
          when :Hit_id
            @sbjct.sbjct_id += characters
          when :Hit_def
            @sbjct.definition += characters
          when :Hit_accession
            @sbjct.accession += characters
          when :Hit_len
            @sbjct.length = characters.to_i

          when :Hsp_num
            @hsp.number = characters.to_i
          when :"Hsp_bit-score"
            @hsp.bit_score = characters.to_i
          when :Hsp_score
            @hsp.score = characters.to_i
          when :Hsp_evalue
            @hsp.evalue = characters.to_f
          when :"Hsp_query-from"
            @hsp.query_from = characters.to_i
          when :"Hsp_query-to"
            @hsp.query_to = characters.to_i
          when :"Hsp_hit-from"
            @hsp.sbjct_from = characters.to_i
          when :"Hsp_hit-to"
            @hsp.sbjct_to = characters.to_i
          when :"Hsp_query-frame"
            @hsp.query_frame = characters.to_i
          when :"Hsp_hit-frame"
            @hsp.sbjct_frame = characters.to_i
          when :Hsp_identity
            @hsp.identity = characters.to_i
          when :Hsp_positive
            @hsp.positive = characters.to_i
          when :"Hsp_align-len"
            @hsp.length = characters.to_i
          when :Hsp_qseq
            @hsp.query_sequence += characters
          when :Hsp_hseq
            @hsp.sbjct_sequence += characters
          when :Hsp_midline
            @hsp.midline += characters
          end
        end

        def end_element(element)
          case element
          when :Iteration
            # end of a query
            @queries << @query
            @query = Query.new
          when :Hit
            # end of a sbjct
            @query.sbjcts << @sbjct
            @sbjct = Sbjct.new
          when :Hsp
            # end of a hsp
            @sbjct.hsps << @hsp
            @hsp = Hsp.new
          end
        end
        
      end # end of MgNu::Parser::Blast::Format7 class
    end # end of MgNu::Parser::Blast class
  end # end of MgNu::Parser module
end # end of MgNu module
