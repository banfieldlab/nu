module Nu
  class Version
    MAJOR = 2
    MINOR = 0
    PATCH = 1
    PRE = nil
    class << self
      # string representation of the version
      #
      # @return [String]
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end
