module GcodeVm
  module Commands
    class Dwell < AbstractCommand

      attr_accessor :seconds
      attr_accessor :words

      def initialize(seconds: nil, words: nil, **kwargs)
        super(**kwargs)
        @seconds = seconds
        if ! seconds.is_a?(Numeric) && words.is_a?(Hash)
          # This is assuming CNC format.
          seconds = words['P']
        end
        @words = words
      end

      def printable_params(formatter)
        digits = formatter.precision
        target = formatter.output_target
        value = seconds

        if target == :dev_kit || target == :marlin
          # Milliseconds on Marlin.
          value *= 1000
        end

        { 'P' => value.round(digits) }
      end

    end
  end
end
