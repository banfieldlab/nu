#require 'nu/sequence'

module Nu
  class Sequence
    class Fastq < Sequence
      attr_accessor :header, :header_name, :header_description
      attr_accessor :quality, :qualhdr, :qualary, :offset

      # create a new Nu::Sequence::Fastq object
      def initialize(options)
        super(options)
        options = {:offset => 64, :header => nil, :quality => nil}.merge! options
        @quality = options[:quality]
        @offset = options[:offset]
        @header = options[:header]
        temp = @header.split
        @header_name = temp.shift
        @header_description = temp.length > 0 ? temp.join(' ') : nil
        @qualhdr = options[:qualhdr] if options[:qualhdr]
      end

      def to_fasta
        Nu::Sequence::Fasta.new(:header => @header, :sequence => sequence)
      end

      # override to_s representation
      def to_s
        "@#{@header}\n#{sequence}\n+\n#{@quality}\n"
      end

      # Unpack the quality string and return an array of
      #  offset-corrected integers
      # @params [Integer] offset platform dependent offset value to
      #  substract from the quality score, defaults to most recent
      #  platform (i.e. illumina)
      #  (64)
      # @return [Array] the array of integers
      def unpack_quality # only compute this one time
        @quality.unpack('C*').map! { |x| x - @offset }
      end
    end # end of Fastq class
  end # end of Sequence class
end # end of Nu module
