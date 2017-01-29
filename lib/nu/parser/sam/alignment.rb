module Nu
  module Parser
    class Sam
      class Alignment
        attr_accessor :name, :flag, :hit, :position, :quality, :cigar, :mate_ref
        attr_accessor :mate_pos, :distance, :sequence, :query_qual, :other
        
        # create a new Alignment object
        def initialize(attributes = {})
          self.attributes = attributes
        end


        def attributes=(attributes = {})
          attributes.each do |attr,value|
            self.send("#{attr}=", value) if self.respond_to?("#{attr}=")
          end
        end
      end
    end
  end
end
