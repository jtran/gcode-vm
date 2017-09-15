module GcodeVm
  # Function application condition.
  #
  # Note: the result is cached so we don't currently support changing the
  # function or arguments at run-time.
  class ApplicationCondition

    # @return [#call] function to call whose return value should be a Condition
    attr_accessor :fun

    # @return [Array] arguments to apply to the function
    attr_accessor :args

    def initialize(fun:, args:)
      @fun = fun
      @args = args
      @applied_cond = nil
      @is_evaled = false
    end

    def call(*runtime_args)
      cond = applied_condition
      result = cond.call(*runtime_args)

      result
    end


    private

    def applied_condition
      # Memoize the result of applying.  This is purely for efficiency since
      # we know the function and arguments never change.
      return @applied_cond if @is_evaled

      # Apply the static arguments to the function to get back another function.
      @applied_cond = @fun.call(*@args)

      if ! @applied_cond.respond_to?(:call)
        raise "the condition you specified doesn't make sense; adding parentheses to the condition may help parse it in the way that you expect: fun=#{fun.inspect}, args=#{args.inspect}"
      end

      # Mark this as evaled *after* checking for errors.
      @is_evaled = true

      @applied_cond
    end

  end
end
