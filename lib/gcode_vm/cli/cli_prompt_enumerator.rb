require 'readline'

module GcodeVm
  # An Enumerator that prompts the user and yields their input.  Uses GNU
  # Readline to prompt the user on STDOUT and reads input from STDIN.
  class CliPromptEnumerator < Enumerator

    def initialize
      @prompt_index = 1
      super do |y|
        while (line = Readline.readline(prompt, true))
          # Don't keep blank lines in history.
          Readline::HISTORY.pop if /\A\s*\Z/ =~ line

          y << line
          @prompt_index += 1
        end
      end
    end

    def prompt
      padded_index = @prompt_index.to_s.rjust(3, '0')

      "#{padded_index} > "
    end

  end
end
