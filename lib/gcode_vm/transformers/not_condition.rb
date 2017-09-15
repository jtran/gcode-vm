module GcodeVm
  # A condition that negates another condition.
  class NotCondition

    attr_accessor :condition

    def initialize(condition:)
      @condition = condition
    end

    def call(obj)
      ! @condition.call(obj)
    end

  end
end
