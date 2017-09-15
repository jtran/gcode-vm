module GcodeVm
  # A condition that's true only *before* a condition.
  #
  # Note: this transformer has state.
  class BeforeCondition

    attr_accessor :end_condition

    def initialize(end_condition:)
      @end_condition = end_condition
      @state = true
    end

    def call(obj)
      if @state
        @state = ! @end_condition.call(obj)

        true
      else
        false
      end
    end

  end
end
