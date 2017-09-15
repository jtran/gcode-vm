module GcodeVm
  # A condition that always returns a constant value.
  class ConstantCondition

    attr_accessor :value

    def initialize(value:)
      @value = value
    end

    def call(*args)
      @value
    end

  end
end
