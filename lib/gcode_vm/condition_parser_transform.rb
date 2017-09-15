module GcodeVm
  # Parslet Transform that takes the raw output of {ConditionParser} and
  # converts it to a Condition instance.  You probably shouldn't need to use
  # this directly.
  #
  # @see Condition.parse
  class ConditionParserTransform < Parslet::Transform

    rule(identifier: simple(:id)) {
      case id
      when 'true'
        ConstantCondition.new(value: true)
      when 'false'
        ConstantCondition.new(value: false)
      else
        IdentifierCondition.new(id: id)
      end
    }

    rule(regexp_body: subtree(:source_subtree), regexp_options: subtree(:options_subtree)) {
      # We should never get a Hash.  We expect either an array or a string for
      # both source and options.
      if options_subtree.respond_to?(:to_ary)
        arr_options = options_subtree
      else
        arr_options = options_subtree.to_s.split('')
      end
      if source_subtree.respond_to?(:to_ary)
        # This case handles zero-length regexps.
        if source_subtree.size > 0
          raise "I was parsing a regular expression, but I didn't expect a non-empty array of regexp_body; this is probably a bug in the parser"
        end
        str_source = ''
      else
        str_source = source_subtree
      end

      regexp = ConditionParserTransform.parse_regexp(str_source, arr_options)

      MatchCondition.new(pattern: regexp)
    }

    rule(range_start: simple(:range_start), range_end: simple(:range_end)) {
      RangeCondition.new(start_condition: range_start, end_condition: range_end)
    }

    rule(range_start: simple(:range_start)) {
      AfterCondition.new(start_condition: range_start)
    }

    rule(range_end: simple(:range_end)) {
      BeforeCondition.new(end_condition: range_end)
    }

    rule(fun_exp: simple(:fun_exp), arg_exp: sequence(:arg_exps)) {
      arg_exps.reduce(fun_exp) {|fun_exp, arg|
        ApplicationCondition.new(fun: fun_exp, args: [arg])
      }
    }

    rule(binary_op: subtree(:binary_op)) {
      # If it's not a hash, it's probably already been parsed into a Condition.
      next binary_op unless binary_op.is_a?(Hash) && binary_op.has_key?(:o)

      operator = binary_op[:o].to_s.strip
      case operator
      when 'and'
        AndCondition.new(conditions: [binary_op[:l], binary_op[:r]])
      when 'or'
        OrCondition.new(conditions: [binary_op[:l], binary_op[:r]])
      else
        raise "Unknown binary operator: operator=#{operator}, binary_op=#{binary_op.inspect}"
      end
    }


    def self.parse_regexp(source, arr_options)
      # The implementation is based off of the Psych YAML parser.
      # https://github.com/ruby/psych/blob/master/lib/psych/visitors/to_ruby.rb
      source = source.to_s
      options = 0
      lang = nil
      arr_options.each do |option|
        case option
        when 'x'
          options |= Regexp::EXTENDED
        when 'i'
          options |= Regexp::IGNORECASE
        when 'm'
          options |= Regexp::MULTILINE
        when 'n'
          options |= Regexp::NOENCODING
        else
          lang = option
        end
      end

      Regexp.new(*[source, options, lang].compact)
    end

  end
end
