module GcodeVm
  # A condition that matches a regular expression pattern.
  class MatchCondition

    attr_accessor :pattern

    def initialize(pattern:)
      @pattern = TransformSpec.maybe_regexp(pattern)
      if ! @pattern.is_a?(Regexp)
        raise "Expected regexp for pattern: #{pattern.inspect}"
      end
    end

    def call(obj)
      case @pattern
      when Regexp
        !! (@pattern =~ obj)
      else
        # TODO
        raise "Arbitrary pattern not implemented"
      end
    end

  end
end
