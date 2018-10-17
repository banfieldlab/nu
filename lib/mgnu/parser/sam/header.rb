module MgNu
  module Parser
    class Sam
      class Header
        include MgNu::Loggable

        attr_accessor :vn, :so, :sq, :rg, :pg, :co

        # create a new Header object
        def initialize(options)
          options = {
            :vn => options.has_key?(:vn) ? options[:vn] : nil,
            :so => options.has_key?(:so) ? options[:so] : nil,
            :sq => options.has_key?(:sq) ? options[:sq] : nil,
            :rg => options.has_key?(:rg) ? options[:rg] : nil,
            :pg => options.has_key?(:pg) ? options[:pg] : nil,
            :co => options.has_key?(:co) ? options[:co] : nil,
          }.merge!(options)
        end
      end
    end
  end
end
