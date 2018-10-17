module MgNu
  class Genbank
    class Feature
      attr_accessor :feature_type, :qualifiers, :location, :sequence
      attr_accessor :start_continues, :stop_continues, :raw_qualifiers

      # create a new Feature object
      def initialize
        @qualifiers = []
        @raw_qualifiers = []
      end

      # for handling tags in gb format
      def method_missing(method_name, *args)
        quals = @qualifiers.select {|q| q.name == method_name.to_s}
        if quals.length > 1
          return quals.map {|q| q.value }
        elsif quals.length == 1
          return quals.first.value
        else
          return nil
        end
      end

      # class method for parsing a gb entry in a buffer
      def self.parse(buffer)
        buffer = buffer.split("\n")
        feature = Feature.new # create a new feature
        buffer.each_with_index do |line,i|
          if line =~ /^\s{5}([\w\-\*']+)\s+(.+)$/ #feature type and (beginning of) location line
            feature.feature_type = Regexp.last_match[1]
            loc = Regexp.last_match[2]

            until buffer[i + 1] =~ /\/.+=.+/ # check for a continuation of Location line
              break unless buffer[i+1]
              loc += buffer[i + 1].lstrip!
              buffer.delete_at(i + 1)
            end
            feature.location = Location.new(loc)
          elsif line =~ /^\s{21}\/(.+)=(.+)$/
            key, value = Regexp.last_match[1], Regexp.last_match[2]

            # to handle multi-line qualifier values
            until buffer[i+1] =~ /^\s{21}\/(?:.+?)=/ # next qualifier
              break unless buffer[i + 1]
              value += " #{buffer[i + 1].lstrip}"
              buffer.delete_at(i + 1)
            end
            # parse out quotes
            quoted = false
            if value =~ /^"(.+)"$/
              value = Regexp.last_match[1]
              quoted = true # some qualifier values are part of a controlled vocabulary and, as such, unquoted
            end
            # make sure sequence contains no spaces
            if key == 'translation'
              value.gsub!(/\s/, '');
            end
            # add new qualifier to feature
            feature.qualifiers << Qualifier.new(:name => key, :value => value.squeeze(' '), :quoted => quoted)
          elsif line =~ /^\s{21}\/(.+)$/ # qualifier name w/out value
            key = Regexp.last_match[1]
            feature.qualifiers << Qualifier.new(:name => key)
          else
            raise "UNKNOWN FEATURE LINE TYPE: #{line} -- #{i}"
          end
        end # end loop through buffer
        feature
      end

      # string representation of Feature
      def to_s
        out = ''
        out += ' ' * 5
        out += feature_type.ljust(16)
        out += location.to_s
        qualifiers.each do |q|
          out += q.to_s
        end
        out 
      end
    end # end MgNu::Genbank::Feature class
  end # end MgNu::Genbank class
end # end MgNu module
