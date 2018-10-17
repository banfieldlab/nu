module MgNu
  module Parser
    class Iprscan
      class Hit
        attr_accessor :query, :crc, :length, :db, :db_id, :db_description
        attr_accessor :from, :to, :evalue, :status, :date
        attr_accessor :ipr_id, :ipr_description, :go

        include MgNu::Loggable

        # create a new Hit object
        def initialize(line = nil)
          @ipr_id = nil
          @ipr_description = nil
          @go = nil

          line.chomp!
          temp = line.split(/\t/)
          @query = temp.shift
          @crc = temp.shift
          @length = temp.shift.to_i
          @db = temp.shift
          @db_id = temp.shift
          @db_description = temp.shift
          @from = temp.shift.to_i
          @to = temp.shift.to_i
          @evalue = temp.shift.to_f
          if @db == "Seg" or @db == "TMHMM" or @db == "Coil"
            @evalue = "NA"
          end
          @status = temp.shift
          @date = temp.shift
          if temp.length > 0
            @ipr_id = temp.shift
            if temp.length > 0
              @ipr_description = temp.shift
              if temp.length > 0
                @go = temp.shift
              end
            end
          end

        end

        def to_s
          str  = "#{@query}\t#{@crc}\t#{@length}\t#{@db}\t#{@db_id}\t#{@db_description}\t"
          str += "#{@from}\t#{@to}\t#{@evalue}\t#{@status}\t#{@date}"
          unless @ipr_id.nil?
            str += "\t#{@ipr_id}\t#{@ipr_description}"
            unless @go.nil?
              str += "\t#{@go}"
            end
          end
          str
        end

        def match_length
          @from < @to ? @to - @from : @from - @to
        end

        def summary
          string  = "#{@db_description} (db=#{@db} db_id=#{@db_id}"
          string += " from=#{@from} to=#{@to}"
          string += " evalue=#{@evalue}" unless db == "Seg" or db == "TMHMM"
          string += " interpro_id=#{@ipr_id} interpro_description=#{@ipr_description}" unless @ipr_id == "NULL"
          string += " GO=#{@go}" unless @go.nil?
          string += ")"
          string
        end

      end
    end # end of MgNu::Parser::Iprscan::Hit class
  end # end of MgNu::Parser module
end # end of MgNu module

__END__
