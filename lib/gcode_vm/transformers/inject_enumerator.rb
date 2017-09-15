module GcodeVm
  class InjectEnumerator < TransformingEnumerator

    # Pattern to match against.  Can be a Regexp, String, or nil.  If it's nil,
    # values will be inserted immediately, the same as always matching.
    attr_accessor :before

    def initialize(before: nil, values: [])
      super(nil)
      @before = TransformSpec.maybe_regexp(before)
      @matched = @before.nil?
      @buffer = Queue.new
      Array.wrap(values).each do |val|
        @buffer << val
      end
    end

    def next
      while true
        # If we have buffered values and have matched, consume that before
        # pulling from the source.  Check the queue size so that in the common
        # case, we don't raise an exception which is probably slower.
        if @matched && @buffer.present?
          begin
            val = @buffer.shift(true)
          rescue ThreadError
            # Queue is empty.
          else
            return transform(val)
          end
        end

        # Pull from the source.
        val = source_enum.next

        # See if it matches.
        match = @before.nil? || @before === val
        @matched = match

        # If it doesn't match, return it.
        #
        # It's common that the buffer is empty.  Instead of adding the value to
        # the queue just to pop it right off during the next iteration, which
        # requires locking, this is an optimization to by-pass that and just
        # return it immdediately.
        if ! match || @buffer.empty?
          return transform(val)
        end

        # Keep the source value for next time *after* all buffered values.
        @buffer << val
      end
    end

    def peek
      raise "inject enumerator doesn't currently implement #peek"
    end

    def size
      # We can't lazily know the size.
      nil
    end

    # Insert a value into the stream.
    def <<(value)
      @buffer << value
    end

  end
end
