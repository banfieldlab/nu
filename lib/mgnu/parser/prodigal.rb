# this is a hack of MgNu::Parser::Genbank to deal specifically with
# prodigal's limited GFF support
require 'mgnu/genbank/feature'
require 'mgnu/genbank/location'
require 'mgnu/genbank/qualifier'

module MgNu
  module Parser
    class Prodigal

      attr_reader :file
      attr_accessor :name, :length, :definition, :features

      include MgNu::Loggable
      include MgNu::Parser
      include Enumerable

      # create a new prodigal parser
      def initialize(filename = nil,debug=false)
        @debug = debug
        if filename
          if File.exists?(filename) and File.readable?(filename)
            @file = File.open(filename)
          else
            error("MgNu::Parser::Prodigal.new(): problems with filename")
            raise "File doesn't exist or is not readable!"
          end
        else
          error("MgNu::Parser::Prodigal.new(): need a filename")
          raise "no filename given!"
        end
      end

      def each
        buffer = parse_until(@file,/^\/\//,false)
        while (buffer.length > 0) do
          buffer.shift if buffer[0] =~ /^\/\//
          yield parse(buffer)
          buffer = parse_until(@file,/^\/\//,false)
        end
      end

      def parse(buffer)
        return if buffer.nil?
        return if buffer.length == 0
        if buffer[0] =~ /^DEFINITION\s+(.+)$/
          pseq = MgNu::Parser::Prodigal::Sequence.new(:definition => $1)
          if buffer[0] =~ /^DEFINITION\s+seqnum=(\d+);seqlen=(\d+);seqhdr="(.+)\s*";gc_cont=([0-9\.]+);transl_table=(\d+).*$/
            buffer.shift
            pseq.seqnum = $1.to_i
            pseq.length = $2.to_i
            pseq.seqhdr = $3
            pseq.gc_cont = $4.to_f
            pseq.transl_table = $5.to_i
            pseq.name = pseq.seqhdr.split(/\s+/)[0]
            #pseq.features = parse_features(buffer)
            pseq.parse_features(buffer)
            return pseq 
          else
            $stderr.puts "ERROR: unknown format for DEFINITION line"
            $stderr.puts buffer[0]
            exit(1)
          end # end if /DEFINITION/
        else
          $stderr.puts "ERROR: buffer didn't begin with DEFINITION"
          $stderr.puts buffer[0]
          exit(1)
        end # end if /DEFINITION/
      end # end of def parse

      # yielded from MgNu::Parser::Prodigal
      class Sequence
        attr_accessor :name, :length, :definition, :features
        attr_accessor :seqnum, :seqhdr, :gc_cont, :transl_table

        def initialize(options = {})
          @name = options.has_key?(:name) ? options[:name] : ""
          @length = options.has_key?(:length) ? options[:length] : ""
          @definition = options.has_key?(:definition) ? options[:definition] : ""
          @seqnum = options.has_key?(:seqnum) ? options[:seqnum] : ""
          @seqhdr = options.has_key?(:seqhdr) ? options[:seqhdr] : ""
          @gc_cont = options.has_key?(:gc_cont) ? options[:gc_cont] : ""
          @transl_table = options.has_key?(:transl_table) ? options[:transl_table] : ""
          @features = Array.new
        end


        def parse_features(buffer)
          buffer.shift if buffer[0] =~ /^FEATURES/
          all_features = split_at_features(buffer.join("\n"))

          all_features.each do |feature_str|
            @features << MgNu::Genbank::Feature.parse(feature_str)
          end
        end # end parse_features

        def split_at_features(str)
          sep = "\001"
          str.gsub(/\n(\s{5}\S)/, "\n#{sep}\\1").split(sep)      
        end

        def to_s
          str = "DEFINITION  seqnum=#{@seqnum};seqlen=#{@length};seqhdr=\"#{@seqhdr}\";gc_cont=#{@gc_cont};transl_table=#{@transl_table}\n"
          str += "FEATURES             Location/Qualifiers\n"
          @features.each do |f|
            str += "#{f.to_s}\n"
          end
          str += '//'
          return str
        end

      end # end of MgNu::Parser::Prodigal::Sequence class
    end # end of MgNu::Parser::Prodigal class
  end # end of MgNu::Parser module
end # end of MgNu module

__END__

DEFINITION  seqnum=1;seqlen=252779;seqhdr="cn_combo_scaffold_29  length_252779 read_count_231853";gc_cont=66.10;transl_table=11;uses_sd=1
FEATURES             Location/Qualifiers
     CDS             complement(<2..85)
                     /note=";gc_cont=0.619;tscore=4.54;"
     CDS             529..1245
                     /note=";gc_cont=0.646;tscore=4.54;"
     CDS             1322..1747
                     /note=";gc_cont=0.688;tscore=4.54;"


        def to_s
          str = ""
          str += ">Feature #{@name}\n"
          @features.each do |f|
            locstr = ""
            if f.location.complement
              if f.location.stop_continues
                locstr += "<#{f.location.stop}\t"
              else
                locstr += "#{f.location.stop}\t"
              end
              if f.location.start_continues
                locstr += ">#{f.location.start}\t"
              else
                locstr += "#{f.location.start}\t"
              end
            else
              if f.location.start_continues
                locstr += "<#{f.location.start}\t"
              else
                locstr += "#{f.location.start}\t"
              end
              if f.location.stop_continues
                locstr += ">#{f.location.stop}\t"
              else
                locstr += "#{f.location.stop}\t"
              end
            end
            str += "#{locstr}gene\n"
            str += "\t\t\tgene\tgene#{count}\n"
            f.qualifiers.sort.each do |qualifier,q|
              str += "\t\t\t#{qualifier}\t#{q.value}\n"
            end
            str += "#{locstr}CDS\n"
            f.qualifiers.sort.each do |qualifier,q|
              str += "\t\t\t#{qualifier}\t#{q.value}\n"
            end
            str += "\t\t\tproduct\tgene_#{@number}p\n"
            str += "\t\t\ttransl_table\t#{@transl_table}\n"
          end # end of features.each
          return str
        end
