module GcodeVm
  class ReplaceTransformer

    attr_accessor :pattern
    attr_accessor :with

    def initialize(pattern:, with:, multiline_output: false)
      if ! multiline_output && /\n/ =~ with
        raise ArgumentError.new("I don't know how to replace a pattern with multiple lines.  \"replace\" works on one line at a time.  Use \"insert\" and \"reject\" transforms instead.")
      end
      @pattern = TransformSpec.maybe_regexp(pattern)
      @with = with
    end

    def call(str)
      if ! str.respond_to?(:gsub)
        # Allow non-strings to pass through.
        return str
      end

      str.gsub(@pattern, @with)
    end

  end
end
