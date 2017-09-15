module GcodeVm
  class SplitEnumerator < TransformingEnumerator

    # Delimiter pattern to match against.  Can be a Regexp or String that's
    # passed to #split on the source value.
    attr_accessor :pattern

    def initialize(pattern:)
      super(nil)
      @pattern = TransformSpec.maybe_regexp(pattern)
      @buffer = []
    end

    def next
      # If we found multiple values last time, consume that before pulling from
      # the source.
      if @buffer.present?
        return transform(@buffer.shift)
      end

      val = source_enum.next
      # Pass nil values through.
      if val.nil?
        return transform(val)
      end

      arr = split_value(val)

      head, *tail = arr
      @buffer = tail

      transform(head)
    end

    def peek
      # TODO: peek is possible, but I don't think anyone cares.
      raise "split enumerator doesn't currently implement #peek"
    end

    def size
      # We can't lazily know the size.
      nil
    end


    protected

    # Given a single value from the source, return an array of values.
    #
    # Subclasses can override this to implement their own split.
    def split_value(value)
      arr = value.split(pattern)
      # If the result of split is empty, it was probably an empty string.
      if arr.empty?
        return [value]
      end

      arr
    end

  end
end
