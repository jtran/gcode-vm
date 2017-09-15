# Note: this file isn't required by default.

require 'pp'
require 'yaml'
require_relative 'cli_common'

module GcodeVm
  class Cli

    attr_accessor :quiet
    attr_accessor :verbose

    def initialize(list: false,
                   filename: nil,
                   parse_transform: false,
                   format: nil,
                   transform_file: nil,
                   unsafe: false,
                   machine_type: 'aerotech',
                   quiet: false,
                   verbose: false)
      @list = list
      @filename = filename
      @parse_transform = parse_transform
      @format = format.to_s.downcase if format
      @transform_file = transform_file
      @unsafe = unsafe
      @machine_type = machine_type
      @quiet = quiet
      @verbose = verbose
    end

    def main(read_stdin:, stdin_enum: $stdin.each_line, sink_io: $stdout)
      if @list
        print_transforms_list(sink_io)
        return
      end

      if @parse_transform
        # TODO: pretty-printing should output to sink_io.
        pp GcodeVm::TransformSpec.parse(@transform_file, allow_unsafe: @unsafe)
        return
      end

      if @filename
        source_file = FileFormatHelper.toolpath_file(@filename, @format)
      end

      # Set up a dependency injection container to load the transforms with.
      #
      # TODO: Allow machine type to be specified by the toolpath file.
      container = if @machine_type.to_s.downcase == 'acs'
        GcodeVm::AcsContainer.new
      else
        GcodeVm::AerotechContainer.new
      end

      # Load transforms.
      transforms = GcodeVm::TransformSpec.load_file(@transform_file,
                     container: container,
                     allow_unsafe: @unsafe,
                     unsafe_error: -> (transform_name) {
                       $stderr.puts "You tried to load an unsafe transform \"#{transform_name}\", but didn't explicitly allow it with the --unsafe option."
                       exit(1)
                     })
      pp transforms if @verbose

      # Add interactive features.
      if interactive?
        # Allow the user to type "quit" or "exit".
        quitting_transform = Proc.new {|raw_line|
          line = raw_line.chomp.strip
          if /\Aquit\z/ =~ line || /\Aexit\z/ =~ line
            raise StopIteration
          else
            raw_line
          end
        }
        transforms.unshift(quitting_transform)

        # When user presses Control-D, print a new line so their shell starts on
        # a clean line.  This must be before the quitting transform in the
        # pipeline.
        new_line_transform = GcodeVm::EachEnumerator.new(on_complete: proc {|e|
          sink_io.puts
        })
        transforms.unshift(new_line_transform)
      end

      if source_file
        file_enum = source_file.lazy_commands_enum

        if read_stdin
          # First pull from the file, then input.
          source_enum = GcodeVm::ConcatEnumerator.new(source_enums: [file_enum, stdin_enum])
        else
          source_enum = file_enum
        end
      else
        source_enum = stdin_enum
      end

      # Build enumerator.
      enum = build_enumerator(source_enum, transforms, container)
      pp enum if @verbose

      # REPL.
      enum.each do |result|
        sink_io.puts result
      end
    ensure
      source_file.close if source_file
    end

    def interactive?
      ! quiet
    end

    def print_transforms_list(sink_io)
      GcodeVm::TransformSpec.transform_names.each do |name|
        sink_io.puts name
      end
    end

    # @return [TransformingEnumerator]
    def build_enumerator(source_enum, transforms, container)
      enum = GcodeVm::TransformingEnumerator.new(source_enum).pipe(transforms)

      # If an Evaluator was injected, add it to the pipeline.
      if container.cached?(:evaluator)
        # Grab the Evaluator that was injected.
        parser = GcodeVm::CommandParser.new
        evaluator = container.lookup(:evaluator)
        # At the very end of the pipeline, evaluate to track machine state.
        each_enum = GcodeVm::EachEnumerator.new do |gcode_line|
          cmd = parser.parse_line(gcode_line)
          evaluator.evaluate_command(cmd)
        end
        enum = enum.pipe(each_enum)
      end

      enum
    end

  end
end
