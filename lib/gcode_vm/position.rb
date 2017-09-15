module GcodeVm
  class Position

    def initialize(axes)
      @axis_names = axes.keys.map(&:to_sym)
      @values = {}
    end

    def zero!
      @axis_names.each do |name|
        @values[name] = 0.0
      end
    end

    def [](axis_name)
      @values[axis_name.to_sym]
    end

    def []=(axis_name, value)
      @values[axis_name.to_sym] = value
    end

    def each_axis
      @values.each_pair do |name, val|
        yield name, val
      end
    end

    # Convert to string.
    def to_s
      "#<#{self.class}:#{self.object_id} @values=#{@values.inspect}>"
    end

    # Convert to a Hash.
    def to_h
      @values.dup
    end

  end
end
