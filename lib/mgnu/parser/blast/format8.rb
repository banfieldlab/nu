require 'mgnu/parser/blast/query'
require 'mgnu/parser/blast/sbjct'
require 'mgnu/parser/blast/hsp'


module MgNu
  module Parser
    class Blast
      class Format8
        include Enumerable

        attr_accessor :queries

        # create a new Format8 parser object
        def initialize(input)
          @query = nil
          @sbjct = nil
          @queries = []

          @input = input
        end

        def each
          @input.each do |line|
            next if line =~ /^#/ # skip comments

            temp = line.split(/\t/)

            query_id = temp.shift

            if @query.nil?
              @query = Query.new
              @query.query_id = query_id
            end

            if @query.query_id == query_id
              # already on this query, so just add the sbject
              extract_sbjct(temp)
            else
              # new query_id, save this one and start on new one
              @query.sbjcts << @sbjct
              @sbjct = nil
              yield @query
              @query = Query.new
              @query.query_id = query_id
              extract_sbjct(temp)
            end
          end
        end
        
        def parse
          @input.each do |line|
            next if line =~ /^#/ # skip comments

            temp = line.split

            query_id = temp.shift

            if @query.nil?
              @query = Query.new
              @query.query_id = query_id
            end

            if @query.query_id == query_id
              # already on this query, so just add the sbject
              extract_sbjct(temp)
            else
              # new query_id, save this one and start on new one
              @query.sbjcts << @sbjct
              @queries << @query
              @sbjct = nil
              @query = Query.new
              @query.query_id = query_id
              extract_sbjct(temp)
            end
          end # end of input.each do |line|

          #grab the last ones, if present
          unless @query.nil?
            @query.sbjcts << @sbjct
            @queries << @query
          end
        end

        def extract_sbjct(input)
          sbjct_id = input.shift
          if @sbjct.nil?
            @sbjct = Sbjct.new
            @sbjct.sbjct_id = sbjct_id
          end

          if @sbjct.sbjct_id == sbjct_id
            extract_hsp(input)
          else
            @query.sbjcts << @sbjct
            @sbjct = Sbjct.new
            @sbjct.sbjct_id = sbjct_id
            extract_hsp(input)
          end
        end

        def extract_hsp(input)
          hsp = Hsp.new
          hsp.identity = input.shift.to_f
          hsp.length = input.shift.to_i
          hsp.mismatches = input.shift.to_i
          hsp.gap_count = input.shift.to_i
          hsp.query_from = input.shift.to_i
          hsp.query_to = input.shift.to_i
          hsp.sbjct_from = input.shift.to_i
          hsp.sbjct_to = input.shift.to_i
          hsp.evalue = input.shift.to_f
          hsp.bit_score = input.shift.to_f
          @sbjct.hsps << hsp
        end

      end # end of MgNu::Parser::Blast::Format8 class
    end # end of MgNu::Parser::Blast class
  end # end of MgNu::Parser module
end # end of MgNu module
