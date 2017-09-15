module GcodeVm
  class AxisScaleTransformer

    # @return [String, Symbol] The axis name to modify.
    attr_accessor :axis

    # @return [Numeric] Factor to multiply axis value by.
    attr_accessor :multiplier

    # @return [GcodeFormatter] formatter used to format numbers.
    attr_accessor :gcode_formatter

    def initialize(axis:, multiplier: 1.0, gcode_formatter: GcodeFormatter.new)
      @axis = axis
      @multiplier = multiplier
      @gcode_formatter = gcode_formatter
    end

    def call(line)
      matches = /\A\s*(?:N\d+\s+)?G(?:0|1|2|3|92)\s.*\b(#{@axis}([\+\-]?\d+[\de\.\+\-]*))/.match(line)
      return line unless matches

      command_value = matches[2].to_f
      transformed_value = command_value * @multiplier

      final_str_value = gcode_formatter.format_number(transformed_value)
      new_axis_param = "#{@axis}#{final_str_value}"
      match_begin = matches.begin(1)
      match_end = matches.end(1)
      new_line = line[0...match_begin] + new_axis_param + line[match_end..-1]

      new_line
    end

  end
end
