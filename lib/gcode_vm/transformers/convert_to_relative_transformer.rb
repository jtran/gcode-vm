module GcodeVm
  # Note: This assumes absolute mode commands.
  #
  # Note: This transformer is stateful, and it will behave incorrectly if it's
  # used with Enumerator#peek.
  class ConvertToRelativeTransformer

    # The axis name to modify.
    attr_accessor :axis

    def initialize(axis:, initial_value: 0.0)
      @axis = axis
      @previous_value = initial_value
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

      relative_value = command_value - @previous_value
      @previous_value = command_value

      new_axis_param = "#{@axis}#{relative_value}"
      match_begin = matches.begin(2)
      match_end = matches.end(2)
      new_line = line[0...match_begin] + new_axis_param + line[match_end..-1]

      new_line
    end

  end
end
