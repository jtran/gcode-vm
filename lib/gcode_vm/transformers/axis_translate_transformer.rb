module GcodeVm
  class AxisTranslateTransformer

    # The axis name to modify.
    attr_accessor :axis

    # Amount to add to axis value.
    attr_accessor :amount

    def initialize(axis:, amount: 0.0)
      @axis = axis

      @amount = amount
    end

    def call(line)
      matches = /\A\s*(?:N\d+\s+)?G(?:0|1|2|3|92)\s.*\b(#{@axis}([\+\-]?\d+[\de\.\+\-]*))/.match(line)
      return line unless matches

      # TODO: This assumes we're in absolute mode.
      command_value = matches[2].to_f

      transformed_value = command_value + @amount

      new_axis_param = "#{@axis}#{transformed_value}"
      match_begin = matches.begin(1)
      match_end = matches.end(1)
      new_line = line[0...match_begin] + new_axis_param + line[match_end..-1]

      new_line
    end

  end
end
