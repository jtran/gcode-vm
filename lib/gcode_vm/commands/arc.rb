module GcodeVm
  module Commands
    class Arc < AbstractCommand

      attr_accessor :axes
      attr_accessor :ccw

      def initialize(ccw:, axes: {}, **kwargs)
        super(**kwargs)
        @ccw = ccw
        @axes = axes
      end

    end
  end
end
