module GcodeVm
  class DSL

    attr_accessor :commands

    def initialize
      clear_commands
    end

    def clear_commands
      @commands = []
    end

    def <<(cmd)
      commands << cmd

      # Allow chaining.
      self
    end

    def move(rapid: false, travel: false, **axes)
      self << Commands::Move.new(axes: axes, rapid: rapid, travel: false)
    end

    def travel(**opts)
      move(travel: true, **opts)
    end

    def rapid(travel: false, **axes)
      self << Commands::Move.new(axes: axes, rapid: true, travel: travel)
    end

    def arc(ccw:, **axes)
      self << Commands::Arc.new(axes: axes, ccw: ccw)
    end

    def home(*axes_names, **axes_map)
      axes = axes_names ? axes_names.reduce({}) {|h, n| h[n] = nil; h } : axes_map
      self << Commands::Home.new(axes: axes)
    end

    def comment(str)
      self << Commands::Comment.new(comment: str)
    end

    # Send a literal string, passing it through without interpreting it.
    def literal(str)
      self << Commands::Literal.new(gcode: str)
    end

    def absolute
      self << Commands::Absolute.new
      yield self if block_given?

      self
    end

    def incremental
      self << Commands::Incremental.new
      yield self if block_given?

      self
    end

    alias_method :relative, :incremental

    def set_position(**axes)
      self << Commands::SetPosition.new(axes: axes)
    end

    def dwell(seconds)
      self << Commands::Dwell.new(seconds: seconds)
    end

  end
end
