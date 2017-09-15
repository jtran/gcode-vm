module GcodeVm
  class EvalRubyTransformer

    # String ruby code to evaluate.
    attr_reader :code

    # Binding to evaluate in.
    attr_accessor :scope

    # True to only evaluate upon call.
    attr_accessor :lazy

    attr_accessor :container

    # This class isn't safe to use with untrusted input.
    def self.unsafe
    end

    def self.needs
      :container
    end

    def initialize(code:, scope: nil, lazy: false,
                   container: nil)
      @scope = scope
      @code = code
      @evaled = nil
      @is_evaled = false
      @instance = nil
      @is_instantiated = false
      @lazy = lazy
      @container = container

      # If not lazy, evaluate immediately.
      instantiated if ! lazy
    end

    def call(obj)
      fn = instantiated
      if fn && fn.respond_to?(:call)
        fn.call(obj)
      else
        # The evaluated code didn't return a callable, so just pass the object
        # through.
        obj
      end
    end

    def code=(code)
      @code = code
      # Dereference all evaluated objects.
      @evaled = nil
      @is_evaled = false
      @instance = nil
      @is_instantiated = false

      instantiated if ! lazy
    end

    def evaled
      # Don't eval the same code more than once.
      return @evaled if @is_evaled

      scope = @scope || Kernel
      @evaled = scope.eval(code)
      @is_evaled = true

      @evaled
    end

    def instantiated
      return @instance if @is_instantiated

      obj = evaled
      if obj.is_a?(Class)
        # If the evaluated code is a class, instantiate it.
        @instance = TransformSpec.instantiate_transform(obj, {}, container)
      else
        # Otherwise, just use the result of the evaluated class.
        @instance = obj
      end
      @is_instantiated = true

      @instance
    end

  end
end
