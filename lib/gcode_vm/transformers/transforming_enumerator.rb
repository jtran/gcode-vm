module GcodeVm
  # TODO: Add the the less-frequently used methods of Enumerators.  For example,
  # the following:
  #
  #     #next_values
  #     #peek_values
  #
  class TransformingEnumerator

    include Enumerable

    attr_accessor :source_enum
    attr_accessor :transformers

    def initialize(source_enum, transformers = [])
      @source_enum = source_enum
      @transformers = transformers
    end

    # Add a transformer to the end of the pipeline.  If an Enumerator is given,
    # it is wired to this Enumerator (using #source_enum=) and returned so that
    # the piping chain can continue.
    #
    # @param transformer [Transformer, TransformingEnumerator, Array] The
    #   transform to append to the pipeline.  If it's an Array, the contents are
    #   piped in order.
    # @return [TransformingEnumerator] The new enumerator.  May be the receiving
    #   instance or a different one so that you can chain calls to #pipe.
    def pipe(transformer = nil, &block)
      if transformer && block
        raise ArgumentError.new("Can't pipe both an argument and block")
      end

      transformer ||= block

      if transformer.respond_to?(:next)
        # We have an Enumerator.
        enum = transformer
        enum.source_enum = self

        enum
      elsif transformer.respond_to?(:to_ary)
        # We have an Array.
        arr = transformer.to_ary
        enum = arr.reduce(self) {|enum, transform|
          enum.pipe(transform)
        }

        enum
      else
        # We have a Transformer.
        transformers << transformer

        self
      end
    end

    def each
      if block_given?
        loop do
          yield self.next
        end
      else
        self
      end
    end

    def next
      transform(source_enum.next)
    end

    def peek
      transform(source_enum.peek)
    end

    def feed(obj)
      source_enum.feed(obj)
    end

    def rewind
      source_enum.rewind
    end

    def size
      source_enum.size
    end

    def transform(value)
      result = value
      transformers.each do |transformer|
        result = transformer.call(result)
      end

      result
    end

  end
end
