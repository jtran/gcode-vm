module GcodeVm
  class AbstractCommand

    attr_accessor :gcode
    attr_accessor :line_number
    attr_accessor :comment
    attr_accessor :meta

    def initialize(gcode: nil,
                   line_number: nil,
                   comment: nil,
                   meta: nil,
                   **kwargs)
      # Note: we ignore extra keyword args since they're probably paramters of
      # an unsupported command type (i.e. Commands::Unknown).
      @gcode = gcode
      @line_number = line_number
      @comment = comment
      @meta = meta || ActiveSupport::HashWithIndifferentAccess.new
      @meta = ActiveSupport::HashWithIndifferentAccess.new(@meta) if ! @meta.is_a?(ActiveSupport::HashWithIndifferentAccess)
    end

    # The YAML parser calls this instead of #initialize.
    def init_with(coder)
      map = coder.map || {}

      initialize(**map.symbolize_keys)
    end

    # The YAML emitter calls this to serialize.
    def encode_with(coder)
      instance_variables.sort.each do |ivar|
        name = ivar.to_s.sub(/\A@/, '')
        if name == 'meta'
          if @meta.present?
            # Don't serialize HashWithIndifferentAccess.  Use a regular mapping.
            coder[name] = @meta.to_h
          end
        else
          val = instance_variable_get(ivar)
          fields_to_omit_when_nil = %w[comment gcode line_number]
          if ! val.nil? || ! name.in?(fields_to_omit_when_nil)
            coder[name] = val
          end
        end
      end
    end

    def ==(obj)
      self.class == obj.class && self.state == obj.state
    end

    alias_method :eql?, :==

    def hash
      state.hash
    end

    def to_gcode(formatter = GcodeFormatter.new)
      formatter.format(self)
    end


    protected

    def state
      instance_variables.map {|ivar| instance_variable_get(ivar) }
    end

  end
end
