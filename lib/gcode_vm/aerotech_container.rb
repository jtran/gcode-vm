module GcodeVm
  # A dependency injection container that registers all the standard stuff we
  # need for running on an Aerotech.
  class AerotechContainer < Container

    def initialize
      super
      register_standard_injections
    end

    def register_standard_injections
      register(:evaluator) {
        Evaluator.new(axes: Machine::AEROTECH_AXES)
      }
    end

  end
end
