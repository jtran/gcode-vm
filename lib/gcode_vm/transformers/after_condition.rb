module GcodeVm
  # A condition that's true only *after* a condition.
  #
  # Note: this transformer has state.
  class AfterCondition

    attr_accessor :start_condition

    def initialize(start_condition:)
      @start_condition = start_condition
      @state = false
    end

    def call(obj)
      if @state
        true
      else
        @state = !! @start_condition.call(obj)

        @state
      end
    end

  end
end
