module MgNu
  class Version
    MAJOR = 2
    MINOR = 1
    PATCH = 0
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
