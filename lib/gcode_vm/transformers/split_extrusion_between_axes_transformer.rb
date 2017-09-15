module GcodeVm
  # Note: This assumes absolute mode commands when an Evaluator isn't given.
  #
  # Note: This transformer is stateful, and it will behave incorrectly if it's
  # used with Enumerator#peek.
  class SplitExtrusionBetweenAxesTransformer

    # @return [Numeric] Weight of new axis.  0 is no change of the source, 1 is
    #   all the new axis.  If the weight object responds to #call, it will be
    #   called with the full input, and the return value should be the numeric
    #   weight.
    attr_accessor :weight

    # @return [String, Symbol] The axis name to draw extrusions from.
    attr_accessor :from_axis

    # @return [String, Symbol] The axis name to split to.
    attr_accessor :to_axis

    # @return [Evaluator] Evaluator used to determine the absolute mode of the
    #   axis.  If no evaluator is given, absolute mode is assumed.
    attr_accessor :evaluator

    # @return [GcodeFormatter] formatter used to format numbers.
    attr_accessor :gcode_formatter

    # Tell the caller that we want an Evaluator injected.
    def self.needs
      :evaluator
    end

    def initialize(from_axis:, to_axis:,
                   weight: 0.0,
                   initial_from_value: 0.0,
                   initial_to_value: 0.0,
                   evaluator: nil,
                   gcode_formatter: GcodeFormatter.new)
      @from_axis = from_axis
      @to_axis = to_axis

      @previous_from_value = initial_from_value
      @total_from_transformed_value = initial_from_value

      @total_to_transformed_value = initial_to_value

      @weight = weight
      @evaluator = evaluator
      @gcode_formatter = gcode_formatter
    end

    def call(line)
      matches = /\A\s*(?:N\d+\s+)?G(0|1|2|3|92)\s.*\b(#{@from_axis}([\+\-]?\d+[\de\.\+\-]*))/.match(line)
      return line unless matches

      command_code = matches[1]
      command_value = matches[3].to_f

      is_set_position = command_code == '92'

      # Note: This assumes we're in absolute mode if no evaluator is used.
      is_absolute = is_set_position ||
                    evaluator.nil? ||
                    evaluator.axis_absolute?(@from_axis)
      if is_absolute
        relative_value = command_value - @previous_from_value
        @previous_from_value = command_value
      else
        relative_value = command_value
        @previous_from_value += command_value
      end

      if is_set_position
        # Track the new position and duplicate it, but don't change the weight.
        @total_from_transformed_value = @previous_from_value
        @total_to_transformed_value = @previous_from_value
      else
        weight = @weight.respond_to?(:call) ? @weight.call(line) : @weight
        transformed_from_value = relative_value * (1 - weight)
        @total_from_transformed_value += transformed_from_value

        to_value = relative_value * weight
        @total_to_transformed_value += to_value
      end

      # Output using the mode we're in.
      final_from_str_value = gcode_formatter.format_number(is_absolute ?
                                                           @total_from_transformed_value :
                                                           transformed_from_value)
      final_to_str_value = gcode_formatter.format_number(is_absolute ?
                                                         @total_to_transformed_value :
                                                         to_value)
      new_axis_param = "#{@from_axis}#{final_from_str_value} #{@to_axis}#{final_to_str_value}"
      match_begin = matches.begin(2)
      match_end = matches.end(2)
      new_line = line[0...match_begin] + new_axis_param + line[match_end..-1]

      new_line
    end

  end
end
