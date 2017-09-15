# Note: AbstractCommand isn't in the Commands module since all classes in the
# Commands module could be whitelisted as being allowed to be used in untrusted
# YAML.
require_relative './abstract_command'
require_relative './commands/absolute'
require_relative './commands/arc'
require_relative './commands/comment'
require_relative './commands/dwell'
require_relative './commands/home'
require_relative './commands/incremental'
require_relative './commands/literal'
require_relative './commands/move'
require_relative './commands/set_position'
require_relative './commands/unknown'

module GcodeVm
  module Commands

    # Convenience method for parsing when using the default parser.
    def self.parse(gcode_line)
      CommandParser.new.parse_line(gcode_line)
    end

  end
end
