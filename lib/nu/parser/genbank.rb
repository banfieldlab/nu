module Nu
  module Parser
    class Genbank
      attr_reader :file
      attr_accessor :genbank_instances

      include Nu::Loggable
      include Nu::Parser

      InvalidGenbankFile = Class.new(StandardError)

      LOCUS_REGEX = /^LOCUS\s+(\S+)\s+(\d+)\s+bp\s+(?:(ss-|ds-|ms-))?(\S+)\s+(?:(\S+)\s+)?(\S+)\s+(\S+)$/

      # create a new Genbank parser
      def initialize(filename)
        @genbank_instances = []

        if filename
          if File.exists?(filename) and File.readable?(filename)
            @file = File.open(filename)
          else
            error("Nu::Parser::Genbank#parse: problems with filename")
            raise "File doesn't exist or is not readable!"
          end
        else
          error("Nu::Parser::Genbank#parse: need a filename")
          raise "no filename given!"
        end
      end

      def parse(debug=false)
        @debug = debug
        # parse_header # also triggers parsing of everything else
        until file.eof? do
          parse_section
        end
        genbank_instances
      end

      def parse_section
        locus_line = file.readline
        if md = locus_line.match(LOCUS_REGEX)
          genbank = Nu::Genbank.new
          info("found a LOCUS line") if @debug
          genbank.locus = Nu::Genbank::Locus.new(*md.captures)
          info("LOCUS name #{genbank.locus.name}") if @debug

          buffer = parse_until(file, /^ACCESSION/)
          if buffer.join =~ /^DEFINITION\s+(.+)$/m
            genbank.definition = $1.gsub(/\n/, ' ').gsub(/\s{2,}/, ' ').strip.chop 
            info genbank.definition if @debug
          end

          buffer = parse_until(file, /^VERSION/)
          # parsing ACESSION number line
          if buffer.join =~ /^ACCESSION\s+(.+)$/
            temp = $1.strip.squeeze(' ').split("\s") 
            # multiple secondary accession numbers possible
            genbank.accession, genbank.secondary_accession = temp.shift, temp
          end
          info "ACCESSION: #{genbank.accession}" if @debug

          buffer = parse_until(file, /^KEYWORDS/)
          # parsing VERSION line
          buffer.each do |line|
            if line =~ /^VERSION\s+(.+)$/
              temp = $1.strip.squeeze(' ').split
              temp.each do |version|
                if version =~ /GI:(\d+)/
                  genbank.geninfo_identifier = $1.to_i
                else
                  genbank.version = version
                end
              end
            elsif line =~ /^DBLINK\s+(.+)$/
              genbank.dblink = $1.strip.squeeze(' ')
            end
          end

          buffer = parse_until(file, /^SOURCE/)

          # parse keywords and optional segment
          keyword_lines = []  
          buffer.each do |line|
            if line =~ /^KEYWORDS\s+(.+)$/
              keyword_lines << $1.strip.squeeze(' ')
            elsif line =~ /^SEGMENT\s+(.+)$/
              genbank.segment = $1.strip.squeeze(' ')
            else
              keyword_lines << line
            end
          end
          k = keyword_lines.join
          unless k == "."
            k_array = k.split(/;\s*/) # keywords are separated by semicolons
            k_array[-1].chop! # gets rid of the period after the last keyword
            genbank.keywords = k_array
          end

          buffer = parse_until(file,/^FEATURES/)

          ri = buffer.index {|l| l =~ /^REFERENCE/ }
          ci = buffer.index {|l| l =~ /^COMMENT/ }         

          if ri && ci
            genbank.source = Nu::Genbank::Source.parse(buffer[0..ri-1])
            parse_references(buffer[ri..ci-1], genbank)
            genbank.comment = buffer[ci..-1].map{|line| line.gsub(/^COMMENT/, '').lstrip!.squeeze(' ')}.join("\n")
          elsif ri
            genbank.source = Nu::Genbank::Source.parse(buffer[0..ri-1])
            parse_references(buffer[ri..-1], genbank)
          elsif ci
            genbank.source = Nu::Genbank::Source.parse(buffer[0..ci-1])
            genbank.comment = buffer[ci..-1].map{|line| line.gsub(/^COMMENT/, '').lstrip!.squeeze(' ')}.join("\n")
          else
            # neither references nor comment line
            genbank.source = Nu::Genbank::Source.parse(buffer)
          end
            
          info genbank.source.common_name if @debug
          info genbank.source.organism if @debug
          info genbank.source.lineage if @debug
                        
          parse_features(parse_until(file, /^ORIGIN/), genbank)
          info "features count: #{genbank.features.length}" if @debug

          parse_sequence(parse_until(file, /\/\//), genbank)
          info "sequence length: #{genbank.sequence.try(:length) || 0}" if @debug
          file.readline # consumes end of section line //
          genbank_instances << genbank
        else
          unless locus_line =~ /^\s*$/
            raise InvalidGenbankFile, "Missing or malformed LOCUS line."
          end
        end
      end

      def parse_features(buffer, genbank)
        buffer.shift if buffer[0] =~ /^FEATURES/
        all_features = split_at_features(buffer.join("\n"))

        all_features.each do |feature_str|
          genbank.features << Nu::Genbank::Feature.parse(feature_str)
        end
      end # end parse_features

      def parse_references(buffer, genbank)
        ref_array = split_at_header_tag(buffer.join("\n"))
        ref_array.each do |ref|
          genbank.references << Nu::Genbank::Reference.parse(ref)
        end
      end

      def parse_sequence(buffer, genbank)
        buffer.shift # drop ORIGIN line
        info("inside parse_sequence") if @debug
        info("buffer is #{buffer.length}") if @debug
        
        unless buffer.empty?
          seq = ""
          bigstr = buffer.join
          seq = bigstr.gsub(/[\d\s]+/, "")
          genbank.sequence = Nu::Sequence.new(:value => seq)
          genbank.features.each do |f|
            f.sequence = f.location.get_sequence(genbank.sequence.value)
          end
        else 
          genbank.sequence = nil
        end
      end

      # splits at lines beginning with capital letter and no preceding space chars 
      def split_at_header_tag(str)
        sep = "\001"
        str.gsub(/\n([A-Z])/, "\n#{sep}\\1").split(sep)
      end  

      def split_at_features(str)
        sep = "\001"
        str.gsub(/\n(\s{5}\S)/, "\n#{sep}\\1").split(sep)      
      end 

    end # end of Nu::Parser::Genbank class
  end # end of Nu::Parser module
end # end of Nu module

__END__
