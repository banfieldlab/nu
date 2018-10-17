module MgNu
  class Genbank
    class Qualifier
      include MgNu::Parser
      attr_accessor :name, :value, :quoted

      # create new Qualifier object
      def initialize(opts = {})
        @name = opts.key?(:name) ? strip_quotes(opts[:name]).downcase : nil
        @value = opts.key?(:value) ? opts[:value] : nil
        @quoted = opts.key?(:quoted) ? opts[:quoted] : false
      end

      # string representation
      def to_s
        out = ("\n" + ' ' * 21)
        out << "/#{name}"
        if value
          out << '='
          out << '"' if quoted
          # calculate max length for first line of qualifier value
          x = 79 - 21 - (name.length + 2) # length of name + equal sign
          x -= 1 if quoted
          if value.length > x
            first_line_max = nil
            x.downto(0).each do |i|
              if value[i].chr =~ /[^\w-]/
                first_line_max = i
                break
              end
            end
            first_line_max ||= x
            out << value[0 .. first_line_max - 1]
            out << "\n"
            out << (' ' * 21 + value[first_line_max .. -1].print_multiline(79, :indent => 21).strip)
          else
            out << value
          end
          out << '"' if quoted
        end
        out
      end
    end # end
  end # end Genbank class
end # end MgNu module
