module GcodeVm
  # Note: This assumes absolute mode commands when an Evaluator isn't given.
  #
  # Note: This transformer is stateful, and it will behave incorrectly if it's
  # used with Enumerator#peek.
  class ExtrusionMultiplierEnumerator < TransformingEnumerator

    # The axis name to modify.
    attr_accessor :axis

    # Factor to multiply axis value by.
    attr_accessor :multiplier

    # @return [Regexp] **deprecated** use condition instead
    attr_accessor :if_matches

    # @return [Condition] multiplication only occurs when condition passes
    attr_accessor :condition

    # @return [Evaluator] Evaluator used to determine the absolute mode of the
    #   axis.  If no evaluator is given, absolute mode is assumed.
    attr_accessor :evaluator

    # @return [GcodeFormatter] formatter used to format numbers.
    attr_accessor :gcode_formatter

    # Tell the caller that we want an Evaluator injected.
    def self.needs
      :evaluator
    end

    def initialize(axis:,
                   multiplier: 1.0,
                   initial_value: 0.0,
                   if_matches: nil,
                   condition: nil,
                   evaluator: nil,
                   gcode_formatter: GcodeFormatter.new)
      super(nil)
      @axis = axis

      @previous_value = initial_value
      @total_transformed_value = initial_value

      @multiplier = multiplier
      @condition = condition
      @evaluator = evaluator
      @gcode_formatter = gcode_formatter
      if ! condition.nil? && ! if_matches.nil?
        raise ArgumentError.new("Can't use both condition and if_matches; if_matches is deprecated; use \"if\" and \"unless\" instead")
      end
      if ! if_matches.nil?
        $stderr.puts "DEPRECATION: using \"if_matches\" in a transform file is deprecated; use \"if\" instead"
      end
      @if_matches = TransformSpec.maybe_regexp(if_matches)
    end

    def next
      line = source_enum.next

      matches = /\A\s*(?:N\d+\s+)?G(0|1|2|3|92)\s.*\b(#{@axis}([\+\-]?\d+[\de\.\+\-]*))/.match(line)
      return transform(line) unless matches

      command_code = matches[1]
      command_value = matches[3].to_f

      is_set_position = command_code == '92'

      # Note: This assumes we're in absolute mode if no evaluator is used.
      is_absolute = is_set_position ||
                    evaluator.nil? ||
                    evaluator.axis_absolute?(@axis)
      if is_absolute
        relative_value = command_value - @previous_value
        @previous_value = command_value
      else
        relative_value = command_value
        @previous_value += command_value
      end

      # If the command is setting the offset, track it, but don't modify it.
      if is_set_position
        @total_transformed_value = @previous_value
        return transform(line)
      end

      if condition_passes?(line)
        mult = @multiplier
      else
        mult = 1
      end
      transformed_value = relative_value * mult
      @total_transformed_value += transformed_value

      # Output using the mode we're in.
      final_str_value = gcode_formatter.format_number(is_absolute ?
                                                      @total_transformed_value :
                                                      transformed_value)
      new_axis_param = "#{@axis}#{final_str_value}"
      match_begin = matches.begin(2)
      match_end = matches.end(2)
      new_line = line[0...match_begin] + new_axis_param + line[match_end..-1]

      transform(new_line)
    end

    def peek
      raise "extrusion multiplier enumerator doesn't currently implement #peek"
    end


    private

    def condition_passes?(line)
      if @condition
        @condition.call(line)
      elsif @if_matches
        !! (@if_matches =~ line)
      else
        true
      end
    end

  end
end
