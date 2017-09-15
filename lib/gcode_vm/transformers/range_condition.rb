module GcodeVm
  # A condition that's true between two other conditions.  This is useful for
  # when you want to match on a start pattern and an end pattern and only want
  # to do something in between those.
  #
  # This is inspired by the flip-flop operator from Ruby, Perl, and sed before
  # it.  The exact logic uses the 3-dot end-exclusive version from Ruby.
  #
  # Note: this transformer has state.
  class RangeCondition

    attr_accessor :start_condition

    attr_accessor :end_condition

    def initialize(start_condition:, end_condition:)
      @start_condition = start_condition
      @end_condition = end_condition
      @state = false
    end

    def call(obj)
      if @state
        @state = ! @end_condition.call(obj)

        return true
      else
        @state = !! @start_condition.call(obj)

        return @state
      end
    end

  end
end
