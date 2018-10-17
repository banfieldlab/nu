require 'moneta'
module MgNu
  module Parser
    class FastaHeaderIndex
      attr_reader :filename, :db_name, :db

      def initialize(filename)
        @filename = filename
        if filename =~ /^.+\.hdr\.tch$/
          @db_name = @filename
        else
          @db_name = @filename + ".hdr.tch"
        end

        if File.exist?(@db_name)
          @db = Moneta.new(:TokyoCabinet, file: @db_name)
        else
          @db = Moneta.new(:TokyoCabinet, file: @db_name)
          parse
        end
      end

      # setup parse method for creating tokyo cabinet
      def parse
        MgNu::Parser::Fasta.new(@filename).each do |f|
          @db[f.header_name] = f.header_description
        end
      end # end of #parse

      def [](name)
        @db[name] ? @db[name] : nil
      end

      def close
        @db.close unless @db.nil?
      end
    end # end of MgNu::Parser::FastaHeaderIndex class
  end # end of MgNu::Parser module
end # end of MgNu module
