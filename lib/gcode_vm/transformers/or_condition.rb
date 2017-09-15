module GcodeVm
  # A condition that's true when any child conditions are true.
  class OrCondition

    attr_accessor :conditions

    def initialize(conditions:)
      @conditions = conditions
    end

    def call(obj)
      @conditions.any? {|cond| cond.call(obj) }
    end

  end
end
