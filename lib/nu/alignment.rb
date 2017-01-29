module Nu
  class Alignment
    include Enumerable
    StrongConservationGroups = %w(STA NEQK NHQK NDEQ QHRK MILV MILF HY FYW).collect { |x| x.split('').sort }
    WeakConservationGroups = %w(CSA ATV SAG STNK STPA SGND SNDEQK NDEQHK NEQHRK FVLIM HFY).collect { |x| x.split('').sort }

    attr_reader :length
    attr_accessor :sequences, :order

    # create a new Alignment object
    def initialize(sequences, order = nil)
      @sequences = sequences
      @order = order
      @length = sequences[sequences.keys[0]].length
    end

    # override each
    def each
      if @order.nil?
        @sequences.each do |name, seq|
          yield seq
        end
      else
        @order.each do |name|
          yield @sequences[name]
        end
      end
    end

    # Returns an array of arrays containing the sequences at the position indicated.
    # Can take a range
    def each_position(range = nil)
      matrix = []
      if @order.nil?
        @sequences.each do |name, seq|
          if range.class == Range
            matrix.push(seq[range].split(//))
          elsif range.class == Fixnum
            matrix.push(seq[range])
          else
            matrix.push(seq.split(//))
          end
        end
      else
        @order.each do |name|
          if range.class == Range
            # correct for 0 indexed arrays
            matrix.push(@sequences[name][(range.begin - 1..range.end - 1)].split(//))
          elsif range.class == Fixnum
            matrix.push(@sequences[name][range - 1].chr)
          else
            matrix.push(@sequences[name].split(//))
          end
        end
      end

      positions = []
      if range.class == Range
        range.each do |pos|
          position = []
          matrix.each do |seq|
            position.push(seq[(pos - 1) - (range.begin - 1)])
          end
          positions << position
          if block_given?
            yield position
          end
        end
        unless block_given?
          positions
        end
      elsif range.class == Fixnum
        position = []
        matrix.each do |seq|
          position.push(seq)
        end
        positions << position
        if block_given?
          yield position
        end
        unless block_given?
          positions
        end
      else
        0.upto(@length-1) do |pos|
          position = []
          matrix.each do |seq|
            position.push(seq[pos])
          end
          positions << position
          if block_given?
            yield position
          end
        end
        unless block_given?
          positions
        end
      end
    end

    def [](range = nil)
      each_position(range)
    end

    def match(range = nil)
      # get the matrix for the whole alignment, or a portion if a
      # range is given
      m = each_position(range) 
      str = ""

      # go through every row (position) in the array from
      # each_position and compute the match symbol.  Concat to str
      m.each do |pos|
        # if there's a gap in the alignment at this pos, return a space
        if pos.index("-") != nil
          str += " "
        else
          # no gaps, so determine strength of column
          p = pos.collect { |c| c.upcase }.sort.uniq
          if p.length == 1
            str += "*"
          elsif StrongConservationGroups.find { |x| (p - x).empty? }
            str += ":"
          elsif WeakConservationGroups.find { |x| (p - x).empty? }
            str += "."
          else
            str += " "
          end
        end
      end
      str
    end

    def to_s
      str = ""
      self.order.each do |name|
        str += "#{name}: #{self.sequences[name]}\n"
      end
      str += self.match + "\n"
      str
    end
  end # end Nu::Alignment class
end # end Nu module
