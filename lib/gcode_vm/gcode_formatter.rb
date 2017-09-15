module GcodeVm
  class GcodeFormatter

    # @return [Boolean] Use true to always output floating point numbers.  Some
    #   CNCs, like Haas, treat integral values differently.
    attr_accessor :always_float

    attr_accessor :axis_map

    # @return [Symbol] specifies the intended output platform, one of:
    #   :aerotech, :dev_kit, :haas, :marlin.
    attr_accessor :output_target

    # @return [Fixnum] number of digits to round to after the decimal point.
    attr_accessor :precision

    # @return [Boolean] Use true to convert axis names to all caps.  Not used if
    #   the axis is in the axis map.
    attr_accessor :upcase_axes

    def initialize(always_float: true, axis_map: {}, output_target: nil, precision: 6, upcase_axes: false)
      @always_float = always_float
      @axis_map = axis_map
      @output_target = output_target
      @precision = precision
      @upcase_axes = upcase_axes
    end

    def format(cmd)
      s = cnc_name(cmd) || ''
      printable_params(cmd).each_pair do |k,v|
        translated_axis = axis_map[k]
        if translated_axis
          axis = translated_axis
        else
          axis = upcase_axes ? k.to_s.upcase : k
        end
        str_val = format_number(v)
        s += " #{axis}#{str_val}"
      end

      if cmd.comment
        s += (s.present? ? ' ' : '') + format_comment(cmd.comment)
      end

      s
    end

    # @return [String] number formatted for an axis value
    # @param x [Integer, Float, nil] axis value to format
    def format_number(x)
      if always_float && ! x.nil? || x.is_a?(Float)
        x = x.to_f
        rounded_val = precision ? x.round(precision) : x
        str = format_float(rounded_val)
      else
        str = x.to_s
      end

      str
    end

    # @return [String] number formatted as a floating-point number for an axis
    #   value, without scientific notation.
    def format_float(x)
      # Using the % operator prevents scientific notation.
      s = '%f' % x

      # Remove trailing zeros after the decimal point to output 1.05 instead of
      # 1.05000.
      s.sub(/(\.\d+?)0+\z/, '\1')
    end

    def format_comment(str)
      if output_target == :haas
        "(#{str})"
      else
        s = str.to_s
        # Ensure there's a space after the semicolon.
        if ! s.starts_with?(' ')
          s = ' ' + s
        end
        ";#{s}"
      end
    end

    def cnc_name(cmd)
      case cmd
      when Commands::Move
        cmd.rapid ? 'G0' : 'G1'
      when Commands::Arc
        cmd.ccw ? 'G3' : 'G2'
      when Commands::Dwell
        'G4'
      when Commands::Home
        'G28'
      when Commands::Absolute
        'G90'
      when Commands::Incremental
        'G91'
      when Commands::SetPosition
        'G92'
      when Commands::Literal
        cmd.gcode
      else
        nil
      end
    end

    def printable_params(cmd)
      if cmd.respond_to?(:printable_params)
        cmd.printable_params(self)
      elsif cmd.respond_to?(:axes)
        cmd.axes
      else
        {}
      end
    end

  end
end
