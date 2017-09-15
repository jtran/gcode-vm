module GcodeVm
  # When encountering an ENABLE command, waits for the axes to actually become
  # enabled by querying the motor state.  The querying happens before pulling
  # the next value, not immediately after finding the ENABLE command.  This only
  # works on ACS.
  class AcsEnsureAxisEnabledEnumerator < TransformingEnumerator

    attr_accessor :acs_socket

    def initialize(acs_socket:)
      super(nil)

      @acs_socket = acs_socket
      @axes = []
    end

    def next
      if @axes.present?
        # Block the transform pipeline and wait for axes to become enabled.
        wait_for_axes
      end

      val = source_enum.next
      if /\A\s*ENABLE\s+(.*)\z/i =~ val
        @axes = parse_axes($1)
      end

      transform(val)
    end


    private

    # Return array of string axes.
    def parse_axes(val)
      axes_in_line = val.strip
      # Strip parens.
      if axes_in_line =~ /\A\(([^\)]*)\)\z/
        axes_in_line = $1
      end
      axes = axes_in_line.split(/\s*,\s*/)

      axes
    end

    # Given that we have axes we need to wait for, actually wait until they're
    # enabled.
    def wait_for_axes
      @axes.each do |axis|
        while true
          query = "?MST(#{axis}).#ENABLED"
          resp = acs_socket.request(query) || ''
          resp = resp.strip
          case resp
          when '1'
            # Motor is enabled.
            break
          when /\A\?\d+/
            raise "There was an error querying the status of a motor when trying to enable it: query=#{query.inspect} resp=#{resp.inspect}"
          end
        end
      end

      @axes = []

    end

  end
end
