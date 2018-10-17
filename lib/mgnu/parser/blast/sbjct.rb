module MgNu
  module Parser
    class Blast
      class Sbjct

        attr_accessor :hsps
        attr_accessor :number, :sbjct_id, :definition, :length
        attr_accessor :accession, :query

        # create a new Sbjct object
        def initialize
          @number = nil
          @sbjct_id = ""
          @definition = ""
          @length = nil
          @accession = ""
          @hsps = []
          @best_hsp = nil
          @query = nil
        end
        
        # searches hsps and looks for the best and returns it's evalue
        def evalue
          # call the best_hsp method and see if result is nil
          best_hsp.nil? ? nil : @best_hsp.evalue
        end # end of Sbjct#evalue
        
        # searches hsps and looks for the best and returns it's
        # bit_score
        def bit_score
          # call the best_hsp method and see if result is nil
          best_hsp.nil? ? nil : @best_hsp.bit_score
        end # end of Sbjct#bit_score
 
        # searches hsps and looks for the best and returns it's
        # identity
        def identity
          # call the best_hsp method and see if result is nil
          best_hsp.nil? ? nil : @best_hsp.identity
        end # end of Sbjct#bit_score

        # searches hsps and looks for the best and sets the instance
        # variable
        def best_hsp
          if @best_hsp.nil?
            if @hsps.length > 0 # have some hsps for this hit
              temp_best = @hsps[0]
              @hsps.each do |h|
                if h.evalue < temp_best.evalue
                  temp_best = h
                end
              end
              @best_hsp = temp_best
            end
          end
          @best_hsp
        end # end of Sbjct#evalue
      end # end of MgNu::Parser::Blast::Sbjct class
    end # end of MgNu::Parser::Blast class

  end # end of MgNu::Parser module
end # end of MgNu module
