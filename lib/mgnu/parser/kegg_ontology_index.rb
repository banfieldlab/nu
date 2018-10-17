module MgNu
  module Parser
    class KeggOntologyIndex
      include TokyoCabinet
      include Enumerable

      attr_reader :filename, :db_name, :db
      alias :ontologies :db

      # create a new KeggOntologyIndex
      def initialize(filename="/work/blastdb/kegg/ko")
        @filename = filename
        @db_name = @filename + ".tch"
        @db = HDB.new
        if File.exists?(@filename) and File.readable?(@filename)
          if File.exists?(@db_name) and File.readable?(@db_name)
            if ! @db.open(@db_name, HDB::OREADER) # open the database read-only
              ecode = hdb.ecode
              $stderr.puts "ERROR: could not open #{@db_name} (code: #{hdb.errmsg(ecode)})"
              exit(1)
            end
          else
            if ! @db.open(@db_name, HDB::OWRITER | HDB::OCREAT | HDB::OLCKNB | HDB::OTSYNC ) # create and open the database rw
              ecode = hdb.ecode
              $stderr.puts "ERROR: could not open #{@db_name} (code: #{hdb.errmsg(ecode)})"
              exit(1)
            end
            parse
          end
        else
          raise "\n\n ERROR -- No file by name (#{@filename}).  Exiting.\n\n"
          exit(1)
        end
      end

      def each
        @db.keys.each do |k|
          yield MgNu::Kegg::Ontology.from_json(@db[k])
        end
      end

      def [](k)
        ko = nil
        if @db[k]
          ko = MgNu::Kegg::Ontology.from_json(@db[k])
        else
          $stderr.puts "warning - #{k} wasn't in the file, ko is nil!"
        end
        ko
      end

      # setup parse method for creating TC
      def parse
        buffer = Array.new
        File.new(@filename).each do |line|
          line.chomp!
          if line =~ /\/\/\//
            ko = parse_ko_buffer(buffer)
            @db[ko.kegg_id] = ko.to_json
            buffer.clear
          else
            buffer << line
          end
        end

        if buffer.length > 0
          ko = parse_ko_buffer(buffer)
          @db[ko.kegg_id] = ko.to_json
        end
      end # end parse method

      def parse_ko_buffer(buffer)
        ko = MgNu::Kegg::Ontology.new
        while buffer.length > 0
          line = buffer.shift
          if line =~ /^ENTRY\s+(\S+)\s/
            ko.kegg_id = $1
          elsif line =~ /^NAME\s+(.+)/
            ko.name = $1
          elsif line =~ /^DEFINITION\s+(.+)/
            ko.definition = $1
            while buffer.length > 0
              dline = buffer.shift
              if dline =~ /^(?:CLASS|DBLINKS|GENES)/
                buffer.unshift(dline)
                break
              else
                ko.definition += dline
              end
            end
          elsif line =~ /^CLASS\s+(.+)/
            class_str = $1 + " "
            while buffer.length > 0
              cline = buffer.shift
              if cline =~ /^(?:DBLINKS|GENES)/
                buffer.unshift(cline)
                break
              else
                class_str += cline + " "
              end
            end

            re = /\s*(.+?)\[PATH:(ko\d+)\]\s*/
            re.global_match(class_str) do |m|
              ko.classes << MgNu::Kegg::Ontology::KeggClass.new(:pathway => m[2], :description => m[1])
            end
            if ko.classes.length == 0
              ko.classes << MgNu::Kegg::Ontology::KeggClass.new(:pathway => "unknown", :description => class_str)
            end
          elsif line =~ /^DBLINKS\s+(.+):\s(.+)/
            database = $1
            names = $2.split(/\s+/)
            while buffer.length > 0
              dline = buffer.shift
              if dline =~ /^GENES\s+(.+):\s(.+)/
                buffer.unshift(dline)
                break
              elsif dline =~ /\s+(.+):\s(.+)/ # new db
                names.flatten.each do |n|
                  next if n == ""
                  ko.dblinks << MgNu::Kegg::Ontology::Dblink.new(:name => n, :database => database)
                end
                database = $1
                names = $2.split(/\s+/)
              else
                names << dline.split(/\s+/)
              end
            end
            names.flatten.each do |n|
              next if n == ""
              ko.dblinks << MgNu::Kegg::Ontology::Dblink.new(:name => n, :database => database)
            end
          elsif line =~ /^GENES\s+(.+):\s(.+)/
            org = $1
            names = $2.split(/\s+/)
            while buffer.length > 0
              gline = buffer.shift
              if gline =~ /\s+(.+):\s(.+)/
                names.flatten.each do |n|
                  next if n == ""
                  ko.genes << MgNu::Kegg::Ontology::Gene.new(:name => n, :organism => org)
                end
                org = $1
                names = $2.split(/\s+/)
              else
                names << gline.split(/\s+/)
              end
            end
            names.flatten.each do |n|
              next if n == ""
              ko.genes << MgNu::Kegg::Ontology::Gene.new(:name => n, :organism => org)
            end
          end # end if /ENTRY/
        end # end buffer.each line
        ko # return the ko object
      end # end of #parse_ko_buffer(buffer)

      def close
        @db.close unless @db.nil?
      end
    end # end of MgNu::Parser::KeggOntologyIndex class
  end # end of MgNu::Parser module
end # end of MgNu module
