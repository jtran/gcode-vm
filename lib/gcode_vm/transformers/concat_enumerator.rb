module GcodeVm
  # Concatenates multiple enumerators into one.  All values are pulled from the
  # first enumerator, then the next, etc.
  class ConcatEnumerator < TransformingEnumerator

    attr_accessor :index

    attr_accessor :source_enums

    def initialize(source_enums: [], start_at: 0)
      super(nil)
      @source_enums = source_enums
      @index = start_at
    end

    def next
      pull_next_value(increment: true)
    end

    def peek
      pull_next_value(increment: false)
    end

    def size
      sizes = source_enums.map(&:size)
      if sizes.any? {|s| s.nil? }
        return nil
      end
      if sizes.any? {|s| s == Float::INFINITY }
        return Float::INFINITY
      end

      sizes.sum
    end


    private

    def pull_next_value(increment:)
      meth = increment ? :next : :peek
      exc = nil
      i = @index
      while i < source_enums.size
        enum = source_enums[i]
        begin
          value = enum.public_send(meth)
        rescue StopIteration => e
          exc = e
        else
          return transform(value)
        end

        @index += 1 if increment
        i += 1
      end

      # If an exception was raised, propagate that instance.
      raise exc if exc

      raise StopIteration
    end

  end
end
