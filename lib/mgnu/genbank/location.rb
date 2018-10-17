require 'mgnu/sequence'

module MgNu
  class Genbank
    class Location
      InvalidLocation = Class.new(StandardError)
      LocationWithRemoteAccession = Class.new(StandardError)

      BASERANGE_REGEX = /
      (?<complement>complement)?\(?
      (?<remote_accession>[A-Z\d\.]+:)?
        (?<start_continues><)?
        (?<start>\d+)\.\.
        (?<stop_continues>>)?
        (?<stop>\d+)
      \)?/x

      attr_accessor :raw_value, :start, :stop, :start_continues, :stop_continues
      attr_accessor :complement, :type, :parts

      # create a new Location object
      def initialize(raw_value)
        @raw_value = raw_value.gsub(/\s/, '')
        parse_raw_value
      end

      # parsing the location from a loc line
      def parse_raw_value
        case raw_value
        when /^complement\(join\((.+)\)/
          @type = 'complement_with_join'
          @complement = true
          @parts = Regexp.last_match[1].split(/,/)
          set_properties_for_join_types
        when /^(?:join|order)\((.+)\)/
          @type = 'join'
          @parts = Regexp.last_match[1].split(/,/)
          set_properties_for_join_types
        when BASERANGE_REGEX
          @type = 'standard'
          set_basic_properties(raw_value)
        when /^(\d+)\.(\d+)$/
          @type = 'between_range'
          @start, @stop = Regexp.last_match[1].to_i, Regexp.last_match[2].to_i
        when /^(\d+)^(\d+)$/
          @type = 'between_adjoining'
          @start, @stop = Regexp.last_match[1].to_i, Regexp.last_match[2].to_i
        when /^(complement)?\(?(\d+)\)?$/
          @type = 'single'
          @complement = !!Regexp.last_match[1]
          @start = Regexp.last_match[2].to_i
        else
          fail InvalidLocation, 'This is not a valid Genbank location'
        end
      end

      def set_properties_for_join_types
        non_remote = parts.select { |part| part !~ /[A-Z\d\.]+:/ }
        if non_remote.length == 1
          set_basic_properties(non_remote.first)
        else
          @complement ||= !!(non_remote.first =~ /complement/)
          # sets start and stop based on first and last non remote part, taking into account complement strand
          stop_match, start_match = nil
          if complement
            stop_match = /(?<stop_continues><)?(?<stop>\d+)/.match(non_remote.first)
            start_match = /\.\.(?<start_continues>>)?(?<start>\d+)/.match(non_remote.last)
          else
            start_match = /(?<start_continues><)?(?<start>\d+)/.match(non_remote.first)
            stop_match = /\.\.(?<stop_continues>>)?(?<stop>\d+)/.match(non_remote.last)
          end
          @start = start_match[:start].to_i
          @stop = stop_match[:stop].to_i
          @start_continues = start_match[:start_continues]
          @stop_continues = stop_match[:stop_continues]
        end
      end

      def set_basic_properties(str)
        md = BASERANGE_REGEX.match(str)
        @complement ||= !!md[:complement]
        @remote_accession = md[:remote_accession]
        # start/stop continues takes into account the complement strand
        @start = complement ? md[:stop].to_i : md[:start].to_i
        @stop = complement ? md[:start].to_i : md[:stop].to_i
        @start_continues = complement ? !!md[:stop_continues] : !!md[:start_continues]
        @stop_continues = complement ? !!md[:start_continues] : !!md[:stop_continues]
      end

      def get_sequence(seq)
        s = case type
            when 'complement_with_join', 'join'
              str = buidup_sequence_from_parts(seq)
              str ? build_sequence(str) : nil
            when 'standard'
              if complement
                build_sequence(seq[stop - 1 .. start - 1])
              else
                build_sequence(seq[start - 1 .. stop - 1])
              end
            when 'single'
              build_sequence(seq[start - 1])
            else
              return nil
            end

        if s && ((%w(single standard).include?(type) && complement) || type == 'complement_with_join')
          s.reverse_complement!
        end
        s
      end

      def buidup_sequence_from_parts(seq)
        to_be_joined = ''
        parts.each do |part|
          md = BASERANGE_REGEX.match(part)
          if md[:remote_accession]
            return nil
          else
            temp = seq[md[:start].to_i - 1 .. md[:stop].to_i - 1]
            temp.tr!('actg', 'tgac').reverse! if md[:complement]
            to_be_joined += temp
          end
        end
        to_be_joined
      end

      def build_sequence(str)
        MgNu::Sequence.new(:value => str, :type => 'dna')
      end

      # string representation
      def to_s
        max = 79 - 21 # max length of location line
        out = ''
        if raw_value.length > max
          split_str = raw_value.scan(/(.{1,#{max}})(,|$)/)
          out += (split_str[0].first + split_str[0].last)
          split_str[1 .. - 1].each do |a, b|
            out << ("\n" + ' ' * 21 + a)
            out << b unless b.empty?
          end
        else
          out << raw_value
        end
        out
      end
    end # end of MgNu::Parser::Genbank::Location
  end # end of MgNu::Parser::Genbank class
end # end of MgNu module
