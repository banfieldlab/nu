require 'moneta'
require 'json'

module Nu
  module Parser
    class FastaIndex
      attr_reader :filename, :db_name, :db, :db_type

      # create a new FastaIndex parser
      def initialize(filename, options = {})
        options = {
          :db_type => :TokyoCabinet
        }.merge!(options)

        @db_type = options[:db_type]

        @filename = filename
        if @db_type == :TokyoCabinet
          if @filename =~ /^.+\.tch$/
            @db_name = @filename
          else
            @db_name = "#{@filename}.tch"
          end
        end

        if db_type == :TokyoCabinet
          @db = Moneta.new(:TokyoCabinet, file: @db_name, type: :hdb)
        end
        parse
      end

      # setup parse method for creating tokyo cabinet
      def parse
        Nu::Parser::Fasta.new(@filename).each do |f|
          name = f.header_name
          description = f.header_description
          @db[name] = { 'description' => description, 'sequence' => f.sequence }.to_json
        end
      end # end of #parse

      def [](name)
        f = nil
        if @db.key?(name)
          d = JSON.parse(@db[name])
          f = Nu::Sequence::Fasta.new(:header => "#{name} #{d['description']}",
                                         :sequence => d['sequence'])
        end
        f
      end

      def close
        @db.close unless @db.nil?
      end

    end # end of Nu::Parser::FastaIndex class
  end # end of Nu::Parser module
end # end of Nu module
