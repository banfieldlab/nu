module Nu
  module Parser
    module Sam
      class Pair
      	
      	attr_accessor :name, :first, :second

        # create a new Pair object
      	def initialize(name, first, second)
      		@name = name
      		@first = first
      		@second = second
      	end

      end
    end
  end
end
