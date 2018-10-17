module MgNu
  module Parser
    class Blast
      class Query

        attr_accessor :number, :query_id, :definition, :length, :sbjcts
        attr_accessor :database, :database_sequence_count, :database_total_letters

        # create a new Query object
        def initialize
          @number = nil
          @query_id = ""
          @definition = ""
          @length = nil
          @sbjcts = []
          @best_hit = nil
          @database = nil
          @database_sequence_count = 0
          @database_total_letters = 0
        end

        # Returns the @best_hit instance variable.  If not set, it
        # will search this query's sbjcts and find the one with the best
        # evalue and return it
        #
        # @return [MgNu::Parser::Blast::Sbjct] the best hit for this
        # query
        def best_hit
          return @best_hit unless @best_hit.nil?
          if @sbjcts.length > 0 # make sure there are some hits
            best_hit = @sbjcts[0]
            @sbjcts.each do |s|
              if s.evalue < best_hit.evalue
                best_hit = s
              end
            end
            @best_hit = best_hit
            return best_hit
          end
          return nil
        end
      end # end of MgNu::Parser::Blast::Query class
    end # end of MgNu::Parser::Blast class
  end # end of MgNu::Parser module
end # end of MgNu module
