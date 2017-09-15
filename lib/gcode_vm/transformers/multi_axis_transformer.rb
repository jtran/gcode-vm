module GcodeVm
  # A transformer that uses a single-axis transformer to work on multiple axes.
  # Each single-axis transformer may need its own state.  Instead of forcing
  # each transformer to implement multi-axis support, this allows any single-
  # axis transformer to be used with multiple axes.
  class MultiAxisTransformer

    # Hash of transformers keyed by axis name.
    attr_accessor :transformers

    # Array of axis names in the order that they will be instantiated and
    # called.
    attr_reader :axes

    def initialize(transformer_factory:, factory_args: [], factory_kwargs: {},
                   axes: [])
      @axes = axes
      @transformers = {}
      axes.each do |axis|
        transformer = transformer_factory.new(*factory_args,
                                              axis: axis,
                                              **factory_kwargs)
        @transformers[axis] = transformer
      end
    end

    def call(obj)
      transformers.values.reduce(obj) {|val, transformer|
        transformer.call(val)
      }
    end

    def axis(name)
      transformers[name]
    end

  end
end
