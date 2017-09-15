module GcodeVm
  class FillPositionTransformer

    # @return [String, Symbol] The axis name to modify.
    attr_accessor :axis

    # @return [Evaluator] Evaluator used to determine the current position of
    #   the axis.
    attr_accessor :evaluator

    # Request that the evaluator be injected.
    def self.needs
      :evaluator
    end

    def initialize(axis:, evaluator:)
      @axis = axis
      @evaluator = evaluator
    end

    def call(line)
      if line !~ /\A\s*(?:N\d+\s+)?G(?:0|1|2|3)\s/ || line =~ /\b#{@axis}[\d\.\+\-e]/
        return line
      end

      if evaluator.axis_relative?(@axis)
        # If the axis is currently in relative mode, it doesn't make sense to
        # add its current position.
        return line
      end

      # If there's a line comment, we need to insert before it.
      comment_index = line.index(';')
      if comment_index
        prefix = line[0...comment_index]
        postfix = line[comment_index..-1]
      else
        prefix = line
        postfix = ''
      end
      new_axis_param = "#{@axis}#{@evaluator.position[@axis]}"
      if ! prefix.ends_with?(' ')
        prefix += ' '
      end

      prefix + new_axis_param + postfix
    end

  end

end
