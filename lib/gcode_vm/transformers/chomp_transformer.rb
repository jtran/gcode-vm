module GcodeVm
  class ChompTransformer

    attr_accessor :separator

    def initialize(separator: $/)
      @separator = separator
    end

    def call(str)
      if str.respond_to?(:chomp)
        str.chomp(@separator)
      else
        # Allow non-strings to pass through.
        str
      end
    end

  end
end
