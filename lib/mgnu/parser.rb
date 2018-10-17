module MgNu
  module Parser
    require_relative 'parser/blast'
    require_relative 'parser/clustalw'
    require_relative 'parser/fasta'
    require_relative 'parser/fasta_index'
    require_relative 'parser/fasta_header_index'
    require_relative 'parser/fastq'
    require_relative 'parser/gff'
    require_relative 'parser/genbank'
    #require_relative 'parser/iprscan_file'
    #require_relative 'parser/kegg_ontology_index'
    #require_relative 'parser/sam'
    #require_relative 'parser/pilercr'
    require_relative 'parser/prodigal'

    # Remove quotes from a string
    #
    # @param [String] input string to strip
    # @return [String] input string with quotes removed
    def strip_quotes(input)
      input = Regexp.last_match[1] if input =~ /^["'](.+)["']$/
      input
    end

    # Reads a file until the given regexp is found
    #
    # @param [File, Regexp, Bool] file object and regular expression to
    #   search for and a boolean indicating whether or not to discard
    #   the regexp line or push it back onto the file
    # @return [Array] lines from file up to but NOT including the
    #   regexp matchline
    def parse_until(file, regexp, discard = true)
      buffer = Array.new
      file.each do |line|
        if line =~ regexp and buffer.length != 0
          # found exit condition
          if discard
            file.seek(-line.length, IO::SEEK_CUR) # push this line back on and return
          end
          return buffer
        else
          buffer << line.chomp
        end
      end # end of file.each do |line|
      return buffer
    end # end of parse_until

  end # end of module Parser
end # end of module MgNu
