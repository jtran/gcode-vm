module GcodeVm
  class InsertEnumerator < TransformingEnumerator

    # Text to insert into the stream before the match.
    attr_accessor :text

    # @return [String, Condition] Condition to insert before.
    attr_accessor :before

    # @return [String, Condition] Condition to insert after.
    attr_accessor :after

    # Split text using this line separator.
    attr_accessor :line_separator

    # Set to true to insert on every match, not just the first one.
    attr_accessor :global

    def initialize(text:,
                   before: nil,
                   after: nil,
                   line_separator: $/,
                   global: false)
      super(nil)
      if before && after
        raise ArgumentError.new("Can't use InsertEnumerator with both before and after; pick one or the other")
      end
      @text = text
      @before = before.respond_to?(:to_str) ? Condition.parse(before) : before
      @after = after.respond_to?(:to_str) ? Condition.parse(after) : after
      @line_separator = line_separator
      @global = global
      @matched_times = 0
      @buffer = []
    end

    def next
      # If we found multiple values last time, consume that before pulling from
      # the source.
      if @buffer.present?
        return transform(@buffer.shift)
      end

      val = source_enum.next
      if ! @global && @matched_times > 0
        return transform(val)
      end

      condition = @before || @after
      match = condition.call(val)
      if ! match
        return transform(val)
      end

      # Track how many times we've matched.
      @matched_times += 1

      results = []
      if @after
        # The matched value comes first.
        results << val
      end

      if @text.respond_to?(:split)
        vals = @text.split(@line_separator)
        results.concat(vals)
      else
        results << @text
      end

      if @before
        # The matched value comes afterwards.
        results << val
      end

      first_value = results.shift
      @buffer = results

      transform(first_value)
    end

    def peek
      # TODO: peek is possible, but I don't think anyone cares.
      raise "insert enumerator doesn't currently implement #peek"
    end

    def size
      # We can't lazily know the size.
      nil
    end

  end
end
