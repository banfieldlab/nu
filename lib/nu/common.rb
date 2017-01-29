module Nu
  # codon table 11 from http://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi
  # standard bacteria/archae/plastid codes
  BACTERIA_CODONS = {'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
                     'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
                     'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
                     'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

                     'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
                     'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
                     'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
                     'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

                     'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
                     'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
                     'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
                     'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

                     'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
                     'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
                     'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
                     'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G'}
end

# example usage of Regexp#global_match
# re = /(\w+)/
# words = []
# re.global_match("cat dog house") do |m|
#   words.push(m[0])
# end
# p words # ["cat", "dog", "house"]
class Regexp
  def global_match(str, &proc)
    retval = nil
    loop do
      res = str.sub(self) do |m|
        proc.call($~) # pass MatchData obj
        ''
      end
      break retval if res == str
      str = res
      retval ||= true
    end
  end # end of global_match
end # end of Regexp class

# add print_multiline method to String class
class String
  def print_multiline(width=80, options={})
    return unless self.length > 0
    indent = ' ' * (options[:indent] || 12)
    x = width - indent.length
    # string broken up with spaces or solid string
    split_str = self.scan(/(.{1,#{x}})(?: +|$)\n?|(.{#{x}})/)
    out = ''
    # print first line without indent
    out += split_str.first[0] || split_str.first[1]

    if split_str.length > 1
      out += "\n"
    end
    # print all other lines with indent
    out += split_str[1..-1].map do |str, other|
      "#{indent}#{str || other}"
    end.join("\n")
    out
  end # end of print_multiline
end
