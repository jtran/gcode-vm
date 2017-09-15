module GcodeVm
  # This is a wrapper for a toolpath file in G-code format.
  class GcodeToolpathFile

    attr_reader :filename

    def initialize(filename)
      @filename = filename
      @file = nil
    end

    def close
      @file.close if @file
    end

    def count_commands
      File.open(@filename) do |file|
        # Count the number of lines in the file.
        return file.each_line.count
      end
    end

    # If you call this without a block, you're responsible for closing it.
    def lazy_commands_enum
      if block_given?
        File.open(@filename) do |file|
          yield file.each_line.lazy, file
        end
      else
        ensure_file_is_open

        @file.each_line.lazy
      end
    end


    private

    def ensure_file_is_open
      @file ||= File.open(@filename)
    end

  end
end
