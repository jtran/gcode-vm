module GcodeVm
  class FileFormatHelper

    @toolpath_formats = [:gcode]
    @toolpath_format_from_extension = {
      '.gcode' => :gcode,
    }
    @toolpath_file_factories = {
      gcode: GcodeVm::GcodeToolpathFile,
    }

    DEFAULT_TOOLPATH_FORMAT = :gcode

    def self.canonical_toolpath_format(filename, format)
      if format
        format = format.to_sym
        unless @toolpath_formats.include?(format)
          raise "Unrecognized toolpath format: #{format}; I only know about the following: #{@toolpath_formats.map(&:to_s).join(', ')}"
        end

        format
      elsif filename.present?
        # Infer format from file name.
        ext = File.extname(filename).downcase
        inferred_format = @toolpath_format_from_extension[ext]

        inferred_format || DEFAULT_TOOLPATH_FORMAT
      else
        DEFAULT_TOOLPATH_FORMAT
      end
    end

    def self.toolpath_file(filename, format)
      canonical_format = FileFormatHelper.canonical_toolpath_format(filename, format)
      factory = @toolpath_file_factories[canonical_format]
      case factory
      when Class
        factory.new(filename)
      else
        factory.call(filename)
      end
    end

    # Register a file format with the given file extensions.  You can provide a
    # Class, Proc, or block which is called with the filename.
    def self.register_file_format(name, file_extensions, factory = nil, &block)
      name = name.to_sym
      @toolpath_formats |= [name]
      Array.wrap(file_extensions).each do |ext|
        @toolpath_format_from_extension[ext] = name
      end
      @toolpath_file_factories[name] = factory || block

      name
    end

  end
end
