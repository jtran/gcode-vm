module GcodeVm
  # Note: This assumes relative mode commands.
  #
  # Note: This transformer is stateful, and it will behave incorrectly if it's
  # used with Enumerator#peek.
  class ConvertToAbsoluteTransformer

    # @return [String, Symbol] The axis name to modify.
    attr_accessor :axis

    # @return [GcodeFormatter] formatter used to format numbers.
    attr_accessor :gcode_formatter

    def initialize(axis:,
                   initial_value: 0.0,
                   gcode_formatter: GcodeFormatter.new)
      @axis = axis
      @previous_value = initial_value
      @gcode_formatter = gcode_formatter
    end

    def call(line)
      matches = /\A\s*(?:N\d+\s+)?G(0|1|2|3|92)\s.*\b(#{@axis}([\+\-]?\d+[\de\.\+\-]*))/.match(line)
      return line unless matches

      command_code = matches[1]
      command_value = matches[3].to_f

      if command_code == '92'
        # Track the new position, but don't change it.
        @previous_value = command_value
        return line
      end

      absolute_value = command_value + @previous_value
      @previous_value = absolute_value

      final_str_value = gcode_formatter.format_number(absolute_value)
      new_axis_param = "#{@axis}#{final_str_value}"
      match_begin = matches.begin(2)
      match_end = matches.end(2)
      new_line = line[0...match_begin] + new_axis_param + line[match_end..-1]

      new_line
    end

  end
end
