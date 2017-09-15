module GcodeVm
  class Evaluator

    attr_accessor :is_absolute
    attr_accessor :position
    attr_accessor :offset
    attr_accessor :axes
    attr_accessor :axis_keys

    # True to clamp movement to the min and max of the axes.
    attr_accessor :clamp_movement

    # When clamping movement, set this to true to also modify the commands to
    # reflect the clamping.
    attr_accessor :clamp_commands

    def initialize(axes: Machine::DEFAULT_AXES,
                   position: nil,
                   offset: nil,
                   clamp_movement: false,
                   clamp_commands: false)
      @axes = axes
      @axis_keys = axes.keys
      @is_absolute = true
      if ! position
        position = Position.new(axes)
        position.zero!
      end
      @position = position
      if ! offset
        offset = Position.new(axes)
        offset.zero!
      end
      @offset = offset
      @clamp_movement = clamp_movement
      @clamp_commands = clamp_commands
    end

    def evaluate(cmds)
      last_result = nil
      Array.wrap(cmds).each do |cmd|
        last_result = evaluate_command(cmd)
      end

      last_result
    end

    def evaluate_command(cmd)
      case cmd
      when Commands::Move
        move(cmd)
      when Commands::Arc
        arc(cmd)
      when Commands::Dwell
        dwell(cmd)
      when Commands::Home
        home(cmd)
      when Commands::Comment
        comment(cmd)
      when Commands::Literal
        literal(cmd)
      when Commands::Absolute
        absolute(cmd)
      when Commands::Incremental
        incremental(cmd)
      when Commands::SetPosition
        set_position(cmd)
      when Commands::Unknown
        literal(cmd)
      else
        raise "Can't evaluate unknown command type: #{cmd.inspect}"
      end
    end

    def move(cmd)
      opts = cmd.axes
      return if opts.empty?

      opts.each_pair do |k, v|
        next if v.nil?

        k = k.to_sym
        axis = axes[k]
        # If we don't know about the axis, ignore it.
        next if axis.nil?

        # Convert to absolute.
        old_v = position[k]
        axis_relative = axis_relative?(axis)
        if axis_relative
          v = old_v + v
        end

        # Ensure we don't move past boundaries.
        if clamp_movement
          min_val = axes[k][:min]
          if min_val
            v = [min_val, v].max
          end
          max_val = axes[k][:max]
          if max_val
            v = [max_val, v].min
          end
        end

        # Track absolute position.
        position[k] = v

        # Store the updated value back to the command.
        if clamp_movement && clamp_commands
          # Convert back to relative if needed.
          v_prime = axis_relative ? v - old_v : v

          opts[k] = v_prime
        end
      end
    end

    def arc(cmd)
      opts = cmd.axes
      # If both X and Y are omitted, it's a full circle and we end up back at
      # the start.
      if opts[:X].present? || opts[:Y].present? || opts['X'].present? || opts['Y'].present?
        move(cmd)
      end
    end

    def dwell(cmd)
    end

    def home(cmd)
      # TODO: where does this move?
    end

    def comment(cmd)
    end

    # Send a literal string, passing it through without interpreting it.
    def literal(cmd)
    end

    def absolute(cmd)
      self.is_absolute = true
    end

    def incremental(cmd)
      self.is_absolute = false
    end

    def absolute?
      is_absolute
    end

    def incremental?
      ! absolute?
    end

    alias_method :relative?, :incremental?

    def set_position(cmd)
      cmd.axes.each_pair do |k, v|
        k = k.to_sym
        next unless axes.has_key?(k)

        offset[k] = physical_position(k) - v
        position[k] = v
      end
    end

    def axis_absolute?(axis)
      unless axis
        raise ArgumentError.new("I can't determine the absolute mode of a falsey axis: #{axis.inspect}")
      end

      if axis.respond_to?(:to_sym)
        axis = axes[axis.to_sym]
      end
      mode = if axis
        axis[:absolute_mode]
      else
        # If there's no configuration for this axis, assume its absolute mode
        # matches the machine.
        :machine
      end

      mode == true || mode == :machine && absolute?
    end

    def axis_relative?(axis)
      ! axis_absolute?(axis)
    end

    # Given a value for an axis, returns the absolute position of it taking into
    # account the current absolute mode.
    def absolute_position(axis, value)
      if axis_relative?(axis)
        position[axis] + value
      else
        value
      end
    end

    # Given a value for an axis, returns the delta from the current position,
    # taking into account the current absolute mode.
    def relative_position(axis, value)
      if axis_relative?(axis)
        value
      else
        value - position[axis]
      end
    end

    # Returns the physical position for the given axis, using the current
    # offset.
    def physical_position(axis)
      position[axis] + offset[axis]
    end

  end
end
