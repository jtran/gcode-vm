module GcodeVm
  # Transformer that calls another transformer based on the result of a
  # condition.
  #
  # Note: Since RangeConditions are stateful, this is potentially stateful too.
  class ConditionalTransformer

    # @return [Condition] condition that's evaluated
    attr_accessor :condition

    # @return [Transformer] transfomer that's applied when the condition is true
    attr_accessor :transformer

    # @return [Transformer] transfomer that's applied when the condition is
    #   false.  If none is given, no transform is used.
    attr_accessor :else_transformer

    def initialize(condition:, transformer:, else_transformer: nil)
      @condition = condition
      @transformer = transformer
      @else_transformer = else_transformer
    end

    def call(obj)
      result = @condition.call(obj)

      if result
        @transformer.call(obj)
      elsif @else_transformer
        @else_transformer.call(obj)
      else
        obj
      end
    end

  end
end
