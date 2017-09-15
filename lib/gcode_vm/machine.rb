module GcodeVm
  module Machine

    # Use floats for min and max so that we output 22.0 instead of 22 for CNC
    # machines.
    #
    # absolute_mode can be true for always absolute, false for always relative,
    # or :machine to use the absolute/relative mode of the machine.
    DEFAULT_AXES = {
      X: {
        min: 0.0,
        max: 150.0,
        absolute_mode: :machine,
      },
      Y: {
        min: 0.0,
        max: 150.0,
        absolute_mode: :machine,
      },
      Z: {
        min: 0.0,
        max: 105.0,
        absolute_mode: :machine,
      },
      E: {
        min: nil,
        max: nil,
        absolute_mode: false,
      },
      F: {
        min: 0.0,
        max: nil,
        absolute_mode: true,
      },
    }.freeze

    ACS_AXES = {
      X: {
        min: 0.0,
        max: 150.0,
        absolute_mode: :machine,
      },
      Y: {
        min: 0.0,
        max: 150.0,
        absolute_mode: :machine,
      },
      Z: {
        min: 0.0,
        max: nil,
        absolute_mode: :machine,
      },
      U: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      V: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      W: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      A: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      B: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      C: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      # Feedrate.
      F: {
        min: 0.0,
        max: nil,
        absolute_mode: true,
      },
      # Ending feedrate.
      P: {
        min: 0.0,
        max: nil,
        absolute_mode: true,
      },
      # Time (i.e. duration).
      T: {
        min: 0.0,
        max: nil,
        absolute_mode: true,
      },
    }.freeze

    AEROTECH_AXES = {
      X: {
        min: 0.0,
        max: 150.0,
        absolute_mode: :machine,
      },
      Y: {
        min: 0.0,
        max: 150.0,
        absolute_mode: :machine,
      },
      Z: {
        min: 0.0,
        max: nil,
        absolute_mode: :machine,
      },
      B: {
        min: 0.0,
        max: 105.0,
        absolute_mode: :machine,
      },
      D: {
        min: 0.0,
        max: 105.0,
        absolute_mode: :machine,
      },
      a: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      b: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      c: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      d: {
        min: nil,
        max: nil,
        absolute_mode: :machine,
      },
      E: {
        min: 0.0,
        max: nil,
        absolute_mode: true,
      },
      F: {
        min: 0.0,
        max: nil,
        absolute_mode: true,
      },
    }.freeze

  end
end
