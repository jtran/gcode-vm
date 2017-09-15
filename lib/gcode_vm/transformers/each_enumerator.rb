module GcodeVm
  # Runs a block of code for each value as it's pulled.
  class EachEnumerator < TransformingEnumerator

    attr_accessor :index

    # Proc to call when progress is made.  Arguments are the value and the
    # 0-based index.
    attr_accessor :on_progress

    # Proc to call when the end of the stream has been reached.  Arguments are
    # the StopIteration exception and the 0-based index.
    attr_accessor :on_complete

    def initialize(initial_index: 0, on_progress: nil, on_complete: nil, &block)
      super(nil)
      if on_progress && block
        raise ArgumentError.new("Can't instantiate EachEnumerator with both on_progress and a block")
      end
      @index = initial_index
      @on_progress = on_progress || block
      @on_complete = on_complete
    end

    def next
      begin
        value = source_enum.next
      rescue StopIteration => e
        # Notify the caller that the end of the stream has been reached.
        if on_complete
          on_complete.call(e, @index)
        end
        raise e
      else
        # Notify the caller that progress was made.
        if on_progress
          on_progress.call(value, @index)
        end
        # Count the number of values pulled from the source.
        @index += 1

        transform(value)
      end
    end

  end
end
