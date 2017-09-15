module GcodeVm
  class SplitMoveEnumerator < SplitEnumerator

    # @return [Array<Symbol>] The axes to split among moves.  Other axes not
    # specified by this field will be be duplicated across moves.
    attr_accessor :axes

    # @return [Array<Symbol>] The axes to treat as travel that contribute to the
    # distance of a move.  This must be a subset of axes.
    attr_accessor :distance_axes

    # @return [Float] moves will be broken up so that each move is never longer
    # than this Euclidean distance.  Must be greater than 0.  Use
    # `Float::INFINITY` as a value greater than all other distances.
    attr_accessor :max_distance

    # @return [Evaluator] used to query the current position of all axes.
    attr_accessor :evaluator

    # @return [GcodeFormatter] formatter used to format numbers.
    attr_accessor :gcode_formatter

    # Tell the caller that we want an Evaluator injected.
    def self.needs
      :evaluator
    end

    def initialize(axes:,
                   distance_axes: axes,
                   max_distance: Float::INFINITY,
                   evaluator: Evaluator.new,
                   gcode_formatter: GcodeFormatter.new)
      super(pattern: nil)
      @axes = axes.map(&:to_sym)
      @distance_axes = distance_axes.map(&:to_sym)
      if max_distance.nil? || max_distance <= 0
        raise ArgumentError.new("max_distance must be greater than 0; given: #{max_distance.inspect}")
      end
      @max_distance = max_distance
      @evaluator = evaluator
      @gcode_formatter = gcode_formatter
    end


    protected

    def split_value(line)
      unchanged_result = [line]

      if max_distance == Float::INFINITY
        return unchanged_result
      end

      matches = /\A(\s*(?:N\d+\s+)?G[01])/.match(line)
      return unchanged_result unless matches

      cmd_prefix = $1
      cmd_postfixes = []
      offset = matches.end(1)
      cmd_axes = {}
      while true
        matches = /\s+([a-zA-Z]+)([\+\-]?\d+[\de\.\+\-]*)/.match(line, offset)
        break if ! matches

        name = $1.to_sym
        str_value = $2
        if name.in?(axes)
          cmd_axes[name] = str_value.to_f
        else
          # Pass through axes that we don't know about.
          cmd_postfixes << "#{name}#{str_value}"
        end

        offset = matches.end(2)
      end
      cmd_postfixes << line[offset .. -1].presence.try(:lstrip)

      if cmd_axes.size == 0
        return unchanged_result
      end

      squared_sum = 0.0
      cmd_axes.each_pair do |axis, val|
        next unless val && axis.in?(distance_axes)
        # Convert to relative amount.
        relative_val = evaluator.relative_position(axis, val)

        squared_sum += relative_val * relative_val
      end
      euclidean_distance = Math.sqrt(squared_sum).to_f

      if euclidean_distance < max_distance
        return unchanged_result
      end

      # G0's stop between each movement, so convert to G1.
      new_cmd_prefix = cmd_prefix.sub(/\bG0\b/, 'G1')

      # Absolute value is to handle the case when max_distance is negative.
      parts = (euclidean_distance / max_distance).abs.ceil
      pos = evaluator.position
      (1..parts).map {|i|
        str_parts = [new_cmd_prefix]
        cmd_axes.each_pair do |axis, val|
          low = evaluator.axis_relative?(axis) ? 0.0 : pos[axis]
          high = val
          cur_val = low + i.to_f * (high - low) / parts
          str_val = gcode_formatter.format_number(cur_val)
          str_parts << "#{axis}#{str_val}"
        end
        str_parts.concat(cmd_postfixes)

        str_parts.compact.join(' ')
      }
    end

  end
end
