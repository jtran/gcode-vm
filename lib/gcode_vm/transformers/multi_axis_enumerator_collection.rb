module GcodeVm
  # A collection that uses a single-axis enumerator to work on multiple axes.
  # Each single-axis enumerator may need its own state.  Instead of forcing each
  # enumerator to implement multi-axis support, this allows any single-axis
  # enumerator to be used with multiple axes.
  #
  # This collection itself isn't an enumerator; it just builds them and stores
  # them for later lookup.
  class MultiAxisEnumeratorCollection

    # Hash of enumerators keyed by axis name.
    attr_accessor :axis_enums

    # Array of axis names in the order that they will be instantiated and
    # called.
    attr_reader :axes

    def initialize(enumerator_factory:, factory_args: [], factory_kwargs: {},
                   axes: [])
      @axes = axes
      @axis_enums = {}
      axes.each do |axis|
        enum = enumerator_factory.new(*factory_args,
                                      axis: axis,
                                      **factory_kwargs)
        @axis_enums[axis] = enum
      end
    end

    def axis(name)
      axis_enums[name]
    end

    def enumerators
      # Always return them in the order given.
      axes.map {|axis| axis_enums[axis] }
    end

  end
end
