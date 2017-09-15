module GcodeVm
  class RenameAxisTransformer

    attr_accessor :from
    attr_accessor :to

    def initialize(from:, to:)
      @from = from
      @to = to
    end

    def call(line)
      matches = /\A\s*(?:N\d+\s+)?G(?:0|1|2|3|92)\s.*\b(#{@from}([\+\-]?\d+[\de\.\+\-]*))/.match(line)
      return line unless matches

      command_value = matches[2]

      new_axis_param = "#{@to}#{command_value}"
      match_begin = matches.begin(1)
      match_end = matches.end(1)
      new_line = line[0...match_begin] + new_axis_param + line[match_end..-1]

      new_line
    end

  end
end
