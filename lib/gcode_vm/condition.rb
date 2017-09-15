module GcodeVm
  # Module for all things related to Conditions.  Conditions are Transformers
  # that return a boolean, and therefore, can be used in the context of
  # conditional if-then-else-type contexts.
  module Condition

    # Parses a string into a Condition instance.
    #
    # @param s [String] string to parse
    def self.parse(s)
      parser = ConditionParser.new
      transform = ConditionParserTransform.new

      tree = parser.parse(s)
      out = transform.apply(tree)

      out
    end

  end
end
