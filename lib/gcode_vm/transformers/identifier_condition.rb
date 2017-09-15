module GcodeVm
  class IdentifierCondition

    attr_accessor :id

    def initialize(id:)
      @id = id
      @evaled = nil
      @is_evaled = false
    end

    def call(*args)
      # This memoization is for *correctness*.  If we didn't do this, each time
      # a caller referred to a transition condition, it would instantiate a new
      # one and its state would be lost.  This is admittedly weird evaluation
      # semantics, but it mimics behavior of the range operator in conditions.
      # Its state is tied to the lexical mention of it.  Otherwise, it wouldn't
      # be useful.
      return @evaled if @is_evaled

      @evaled = case id
      when 'changing_to'
        TransitionCondition.new(condition: args[0], transition: :to_truthy)
      when 'changing_from'
        TransitionCondition.new(condition: args[0], transition: :to_falsey)
      when 'not'
        NotCondition.new(condition: args[0])
      else
        raise "I don't know how to evaluate IdentifierCondition with id=#{id.inspect}; I really only know changing_to, changing_from, and not"
      end

      # Only mark as memoized *after* checking errors.
      @is_evaled = true

      @evaled
    end

  end
end
