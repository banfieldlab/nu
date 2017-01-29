require 'strscan'
require_relative 'sequence/fasta'
require_relative 'sequence/fastq'

module Nu
  class Sequence
    attr_accessor :type, :value

    def initialize(options)
      options = {:value => nil, :type => nil}.merge! options
      @value = options[:value]
      @value = options[:sequence] if options.key?(:sequence)
      @type = options[:type]
    end

    alias_method :sequence, :value
    alias_method :sequence=, :value=

    def rna?
      @type == 'rna' ? true : false
    end

    def dna?
      @type == 'dna' ? true : false
    end

    def aa?
      @type == 'aa' || @type == 'aminoacid' || @type == 'protein' ? true : false
    end

    alias_method :protein?, :aa?
    alias_method :aminoacid?, :aa?

    def length
      @value.nil? ? nil : @value.length
    end

    # returns a string
    def complement
      if @type == 'rna'
        @value.tr('ucgtrymkdhvbUCGTRYMKDHVB', 'agcuyrkmhdbvAGCUYRKMHDBV')
      else
        @value.tr('acgtrymkdhvbACGTRYMKDHVB', 'tgcayrkmhdbvTGCAYRKMHDBV')
      end
    end

    # changes sequence @value
    def complement!
      @value = complement
    end

    def reverse_complement
      complement.reverse
    end
    alias_method :revcomp, :reverse_complement

    def reverse_complement!
      @value = complement.reverse
    end
    alias_method :revcomp!, :reverse_complement!

    def translate(frame = 1, cdn_table = Nu::BACTERIA_CODONS)
      from, sequence = nil, @value

      case frame
      when 1, 2, 3
        from = frame - 1
      when 4, 5, 6
        from = frame - 4
        sequence = reverse_complement
      when -1, -2, -3
        from = -1 - frame
        sequence = reverse_complement
      else
        $stderr.puts 'unknown frame - defaulting to zero (0)'
        from = 0
      end

      nalen = sequence.length - from
      nalen -= nalen % 3
      sequence[from, nalen].downcase.gsub(/.{3}/) { |codon| cdn_table[codon] || 'X' }
    end

    def translate!(frame = 1, cdn_table = Nu::BACTERIA_CODONS)
      @value = translate(frame, cdn_table)
    end

    def to_s(cols = 60)
      seq = ''
      if @value.length < cols
        seq = @value
      else
        0.step(@value.length, cols) { |segment| seq += @value[segment, cols] + "\n" }
      end
      seq
    end

    # Genbank formatted sequence 6 cols w/10 letters each, right justified line numbers
    #   1 tcctgatctc ctttatagca ctttccgtga aaattgccaa gcgacctgca tgagttccgg
    #  61 gagcgagaac ttctgcattt aactcacgag gagtaacaat atccactcca ggcagattcc
    # 121 tgaaaccctt cagaacatta tccttgttgg atacaactat caaaacgctc ttctttttct
    def to_genbank
      i = 1
      result = @value.gsub(/.{1,60}/) do |s|
        s = s.gsub(/.{1,10}/, ' \0')
        y = format('%9d%s\n', i, s)
        i += 60
        y
      end
      result
    end

    # returns an array of 1-based positon ranges after splitting on N-blocks > length
    def nblocks(length = 10)
      pieces = []
      prev = 1
      seq = StringScanner.new(value) # the sequence
      while seq.scan_until(/[Nn]{#{length},}/) # only splits at N stitches that are >10, but that can be changed
        pieces << (prev .. seq.pos - seq.matched.length)
        prev = seq.pos + 1
      end
      pieces << (prev .. value.length) # add last piece
      pieces
    end

    def levenshtein_distance(other)
      # initialize
      a, b, m = '', '', []

      # one or the other strings are empty or the strings are the same
      return -1 if @value.nil? || @value == ''
      a = @value.upcase

      if other.class == Nu::Sequence
        return -1 if other.value == '' || other.value.nil?
        b = other.value.upcase
        return 0 if other.value.upcase == @value.upcase
      elsif other.class == String
        return -1 if other == ''
        b = other.upcase
        return 0 if other.upcase == @value.upcase
      end

      0.upto(a.length) { |x| m[x] = [x] }
      1.upto(b.length) { |x| m[0] << x }

      1.upto(a.length) do |x|
        1.upto(b.length) do |y|
          cost = a[x - 1] == b[y - 1] ? 0 : 1
          m[x][y] = [m[x - 1][y] + 1, m[x][y - 1] + 1, m[x - 1][y - 1] + cost].min
        end
      end
      m[-1][-1]
    end # end of levenshtein_distance

    alias_method :distance, :levenshtein_distance

    def percent_identity(other)
      # one or the other strings are empty or the strings are the same
      return -1 if @value.nil? || @value == ''
      a = @value
      b = ''

      if other.class == Nu::Sequence
        return -1 if other.value == '' || other.value.nil?
        b = other.value
        return 1.0 if other.value == @value
      elsif other.class == String
        return -1 if other == ''
        b = other
        return 1.0 if other == @value
      end

      if a.length != b.length
        warn('lengths differ - percent identity may is probably inaccurate')
      end

      match = 0
      a.split(//).each_with_index do |char, i|
        match += 1 if char.upcase == b[i].chr.upcase
      end

      a.length >= b.length ?  match / a.length.to_f : match / b.length.to_f
    end # end of percent_identity

    alias_method :identity, :percent_identity

    def gc_content
      return -1 if @value == '' || @value.nil?
      base2count = {'A' => 0, 'C' => 0, 'G' => 0, 'T' => 0, 'U' => 0,
                    'R' => 0, 'Y' => 0, 'M' => 0, 'K' => 0, 'W' => 0,
                    'S' => 0, 'B' => 0, 'D' => 0, 'H' => 0, 'V' => 0}
      temp = @value.split(//)
      temp.each do |base|
        next if base == '*' || base.upcase == 'N'
        if base2count.key?(base.upcase)
          base2count[base.upcase] += 1
        else
          $stderr.puts "Unknown character #{base.upcase}"
        end
      end
      gc = base2count['G'] + base2count['C'] + base2count['R'] + base2count['K'] + base2count['S'] + base2count['B'] + base2count['D'] + base2count['V']
      total = base2count.values.inject(0) { |a, e| a + e.nil? ? 0 : e }
      format('%.4f', (gc.to_f / total.to_f))
    end
  end # end of Sequence class
end # end of Nu  module
