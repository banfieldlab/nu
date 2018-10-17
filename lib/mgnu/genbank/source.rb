module MgNu
  class Genbank
    class Source
      attr_accessor :organism, :common_name, :lineage

      def initialize(common_name = nil, organism = '', lineage = '')
        @common_name = common_name
        @organism = organism
        @lineage = lineage
      end

      # class method for parsing a buffer of Source data
      def self.parse(buffer)
        s = Source.new
        buffer.each do |line|
          if line =~ /^SOURCE\s+(.+)$/
            s.common_name = Regexp.last_match[1].strip.squeeze(' ')
          elsif line =~ /ORGANISM\s+(.+)/
            s.organism += Regexp.last_match[1].strip.squeeze(' ')
          elsif line =~ /[\w]+;\s/ # lineage line reached
            temp = line.strip.squeeze(' ')
            s.lineage += s.lineage.empty? ? temp : " #{temp}"
          end
        end
        s.lineage.chop! if s.lineage =~ /(.+)\.$/ # remove period at the end
        s
      end

      def to_s
        out = ''
        out << "#{'SOURCE'.ljust(12)}#{common_name}\n"
        out << "  #{'ORGANISM'.ljust(10)}#{organism.print_multiline}\n"
        out << ''.ljust(12) # first lineage line
        out << lineage.print_multiline unless lineage.empty?
        out << '.'
      end
    end # end MgNu::Parser::Genbank::Source class
  end # end of MgNu::Parser::Genbank class
end # end of MgNu module
