module GcodeVm
  # A Condition that's true only when another Condition is changing from its
  # previous value.
  class TransitionCondition

    # @return [Condition] the condition to detect transitions of
    attr_accessor :condition

    # @return [:to_truthy, :to_falsey, :any] the type of transition to detect
    attr_accessor :transition

    # @return [Boolean] the previous value of the condition
    attr_accessor :previous_value

    def initialize(condition:, transition:, previous_value: nil)
      unless [:to_truthy, :to_falsey, :any].include?(transition)
        raise ArgumentError.new("For a TransitionCondition, I only understand :to_truthy, :to_falsey, or :any, but you gave: #{transition.inspect}")
      end
      @condition = condition
      @transition = transition
      if previous_value.nil?
        previous_value = ! (transition == :to_truthy || transition == :any)
      end
      @previous_value = previous_value
    end

    def call(obj)
      new_value = @condition.call(obj)

      rising = @transition == :to_truthy || @transition == :any
      falling = @transition == :to_falsey || @transition == :any

      result = rising && ! @previous_value && new_value ||
               falling && @previous_value && ! new_value

      @previous_value = new_value

      result
    end

  end
end
