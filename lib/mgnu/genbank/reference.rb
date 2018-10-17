module MgNu
  class Genbank
    class Reference
      attr_accessor :title, :number, :base_range, :authors, :journal
      attr_accessor :consrtm, :pubmed, :remark

      # create a new Reference object
      def initialize
        @title = nil
        @base_range = nil
        @number = nil
        @authors = []
        @consrtm = nil
        @journal = nil
        @pubmed = nil
        @remark = nil
      end

      # REFERENCE   1  (bases 1 to 9334)
      #   AUTHORS   Morowitz,M.J., Denef,V.J., Costello,E.K., Thomas,B.C., Relman,D.A.
      #             and Banfield,J.F.
      #   TITLE     Direct Submission
      #   JOURNAL   Submitted (08-APR-2011) Earth and Planetary Sciences, University of
      #             California - Berkeley, 369 McCone Hall, Berkeley, CA 94720, USA
      #   REMARK    Strain-resolved community genomic analysis of gut microbial
      #             colonization in a premature infant

      # class method to parse raw ref line
      def self.parse(raw_string)
        ref = Reference.new
        buffer = raw_string.split("\n")
        buffer.each_with_index do |line, i|
          line.chomp!
          if line =~ /^REFERENCE\s+(\d+)/
            ref.number = Regexp.last_match[1].to_i
            if line =~ /\(bases (\d+) to (\d+)\)/
              ref.base_range = Range.new(Regexp.last_match[1].to_i, Regexp.last_match[2].to_i)
            end
          elsif line =~ /AUTHORS\s+(.+)/
            author_line = Regexp.last_match[1]
            while next_line = buffer[i + 1]
              if next_line =~ /^\s*[A-Z]+\s/ # break if next sub-header line reached
                break
              else
                author_line += next_line
                buffer.delete_at(i + 1)
              end
            end
            # process author_line
            authors = author_line.split(/,\s+/)
            last_author = authors.pop
            authors += last_author.split(/\s*and\s*/)
            ref.authors = authors
          elsif line =~ /^\s*([A-Z]+)\s+(.+)/
            type, content_line = Regexp.last_match[1], Regexp.last_match[2]
            next unless ref.respond_to?(type.downcase.to_sym)
            while next_line = buffer[i + 1]
              if next_line =~ /^\s*[A-Z]+\s/
                break
              else
                content_line += next_line
                buffer.delete_at(i + 1)
              end
            end
            # process content_line
            ref.send(:"#{type.downcase}=", content_line.strip.squeeze(' '))
          end
        end
        ref
      end

      def to_s
        out = ''
        out += "#{'REFERENCE'.ljust(12)}#{number}"
        if base_range
          out += number.to_s.length == 1 ? '  ' : ' '
          out += "(bases #{base_range.first} to #{base_range.last})\n"
        else
          out += "\n"
        end
        if authors.any?
          out += "  #{'AUTHORS'.ljust(10)}"
          case authors.length
          when 1
            out += authors[0]
          when 2
            out += "#{authors[0]} and #{authors[1]}"
          else
            out += "#{authors[0...-1].join(', ')} and #{authors[-1]}".print_multiline
          end
          out += "\n" unless [consrtm, title, journal, remark].none?
        end
        if consrtm
          out += "  #{'CONSRTM'.ljust(10)}#{consrtm.print_multiline}"
          out += "\n" unless [title, journal, remark].none?
        end
        if title
          out += "  #{'TITLE'.ljust(10)}#{title.print_multiline}"
          out += "\n" unless [journal, remark].none?
        end
        if journal
          out += "  #{'JOURNAL'.ljust(10)}#{journal.print_multiline}"
          out += "\n" unless [pubmed, remark].none?
        end
        out += "   #{'PUBMED'.ljust(9)}#{pubmed}" if pubmed
        if remark
          out += "\n"
          out += "  #{'REMARK'.ljust(10)}#{remark.print_multiline}"
        end
        out
      end
    end # end MgNu::Parser::Genbank::Reference class
  end # end of MgNu::Parser::Genbank class
end # end of MgNu module
