module GcodeVm
  class RejectEnumerator < TransformingEnumerator

    # @return [Condition] condition for when reject
    attr_accessor :condition

    # @return [#===] pattern to match against.  Can be a Regexp, String,
    #   Numeric, or anything that responds to #===.
    attr_accessor :pattern

    def initialize(condition: nil, pattern: nil)
      super(nil)
      @condition = condition
      @pattern = TransformSpec.maybe_regexp(pattern)
      if condition.nil? && pattern.nil?
        raise ArgumentError.new("Missing condition; use \"if\" or \"unless\" to specify a condition")
      end
      if ! condition.nil? && ! pattern.nil?
        raise ArgumentError.new("Can't use both condition and pattern; pattern is deprecated; use \"if\" and \"unless\" instead")
      end
      if ! pattern.nil?
        $stderr.puts "DEPRECATION: using \"pattern\" for \"reject\" in a transform file is deprecated; use \"if\" instead"
      end
    end

    def next
      begin
        val = source_enum.next
      end while condition_passes?(val)

      transform(val)
    end

    def peek
      raise "reject enumerator is incompatible with use of #peek"
    end

    def size
      # We can't lazily know the size.
      nil
    end


    private

    def condition_passes?(val)
      if @condition
        @condition.call(val)
      else
        @pattern === val
      end
    end

  end
end
