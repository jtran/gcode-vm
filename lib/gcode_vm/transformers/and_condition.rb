module GcodeVm
  # A condition that's true when all child conditions are true.
  class AndCondition

    attr_accessor :conditions

    def initialize(conditions:)
      @conditions = conditions
    end

    def call(obj)
      @conditions.all? {|cond| cond.call(obj) }
    end

  end
end
