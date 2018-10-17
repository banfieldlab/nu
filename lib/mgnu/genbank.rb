require 'forwardable'
require 'mgnu/genbank/feature'
require 'mgnu/genbank/location'
require 'mgnu/genbank/qualifier'
require 'mgnu/genbank/reference'
require 'mgnu/genbank/source'

module MgNu
  class Genbank
    attr_accessor :locus, :definition, :accession, :secondary_accession, :version, :dblink
    attr_accessor :geninfo_identifier, :keywords, :segment, :source, :references, :comment
    attr_accessor :features, :sequence
    include MgNu::Loggable
    extend Forwardable

    STRUCTURE = [:locus, :definition, :accession, :version, :dblink,
                 :keywords, :segment, :source, :references, :comment,
                 :features, :sequence]

    Locus = Struct.new :name, :length, :no_of_strands, :molecule_type, :molecule_structure, :genbank_division, :modification_date  do
      def to_s
        str = ''
        str << 'LOCUS'.ljust(12) # 1-12
        str << name.ljust(17) # 13-29
        str << length.rjust(11) # 30-41
        str << ' bp ' # 41-44
        str << "#{no_of_strands}".ljust(3) # ss- ds- ms-, 45-47
        str << "#{molecule_type}".ljust(8) # 48-55
        str << "#{molecule_structure}".ljust(8) # linear or circular, 56-63
        str << " #{genbank_division} " # 65-68
        str << modification_date # 69
      end
    end

    # create a new Genbank object
    def initialize
      @locus               = nil
      @definition          = ''
      @accession           = ''
      @secondary_accession = []
      @dblink              = ''
      @version             = ''
      @geninfo_identifier  = ''
      @keywords            = nil
      @segment             = ''
      @source              = nil
      @references          = []
      @comment             = ''
      @features            = []
      @sequence            = ''
    end

    def_delegators :@locus, :name, :length, :no_of_strands, :molecule_type
    def_delegators :molecule_structure, :genbank_division, :modification_date

    # string representation
    def to_s
      str = ''
      STRUCTURE.each do |part|
        p = send(part)
        p_exists = false
        case part
        when :locus, :source
          if p
            p_exists = true
            str << p.to_s
          end
        when :definition, :dblink, :segment, :comment
          if p && !p.empty?
            p_exists = true
            str << part.to_s.upcase.ljust(12)
            str << p.print_multiline
            str << '.' if part == :definition
          end
        when :accession
          if p && !p.empty?
            p_exists = true
            str += 'ACCESSION'.ljust(12)
            str += accession
            if secondary_accession.any?
              str += " #{secondary_accession.join(' ')}"
            end
          end
        when :version
          if p && !p.empty?
            p_exists = true
            str += 'VERSION'.ljust(12)
            str += version
            str += "  GI:#{geninfo_identifier}" if geninfo_identifier
          end
        when :features, :references
          unless p.empty?
            p_exists = true
            str += "FEATURES             Location/Qualifiers\n" if part == :features
            temp = p.collect { |x| x.to_s }
            str += temp.join("\n")
          end
        when :sequence
          unless p.value.empty?
            p_exists = true
            str << "#{'ORIGIN'.ljust(12)}\n"
            str << @sequence.to_genbank
          end
        when :keywords
          p_exists = true
          str << 'KEYWORDS'.ljust(12)
          str << p.join('; ').print_multiline if p
          str << '.'
        end
        # print newline character if there are more parts
        str << "\n" if p_exists && STRUCTURE[STRUCTURE.index(part) + 1]
      end
      str << '//'
    end
  end # end of MgNu::Parser::Genbank class
end # end of MgNu module
__END__
