module GcodeVm
  # Parslet Parser that parses Condition strings and outputs Hashes and Arrays.
  # You probably shouldn't need to use this directly.
  #
  # @see Condition.parse
  class ConditionParser < Parslet::Parser

    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:lparen) { str('(') >> spaces? }
    rule(:rparen) { str(')') >> spaces? }
    rule(:three_dots) { str('...') >> spaces? }

    rule(:and_op) { str('and') >> spaces? }
    rule(:or_op) { str('or') >> spaces? }

    # These won't be parsed as identifiers.
    rule(:any_keyword) {
      str('and') |
      str('or')
    }

    rule(:identifier) {
      (
        # Not starting with a keyword.
        any_keyword.absent? >>
        match('[[:alpha:]]') >> match('[[[:alnum:]]_]').repeat |
        # Starting with a keyword and has at least one other character.
        any_keyword >> match('[[[:alnum:]]_]').repeat(1)
      ).as(:identifier) >>
      spaces?
    }

    rule(:regexp_body) {
      str('/') >> (
        str('\\') >> any | str('/').absent? >> any
      ).repeat.as(:regexp_body) >> str('/')
    }

    rule(:regexp_options) {
      (str('m') | str('i') | str('x') | str('n')).repeat.as(:regexp_options) >>
      spaces?
    }

    rule(:regexp) {
      regexp_body >> regexp_options
    }

    # Non-associative, meaning it cannot be used multiple times in an expression
    # without parentheses to specify the evaluation order.
    rule(:range) {
      three_dots >> range_atom.as(:range_end) |
      range_atom.as(:range_start) >> three_dots >> range_atom.as(:range_end) |
      range_atom.as(:range_start) >> three_dots
    }

    rule(:range_atom) {
      identifier |
      regexp |
      lparen >> condition >> rparen
    }

    # Function application.  Left-associative.
    rule(:application) {
      identifier.as(:fun_exp) >> application_atom.repeat(1).as(:arg_exp)
    }

    rule(:application_atom) {
      range |
      range_atom
    }

    rule(:binary_op_atom) {
      application |
      application_atom
    }

    rule(:condition) {
      infix_expression(binary_op_atom, [and_op, 2, :left],
                                       [or_op,  1, :left]).as(:binary_op)
    }

    rule(:top) { spaces? >> condition >> spaces? }

    root(:top)

  end
end
