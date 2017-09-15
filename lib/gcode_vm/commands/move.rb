module GcodeVm
  module Commands
    class Move < AbstractCommand

      attr_accessor :axes
      attr_accessor :travel
      attr_accessor :rapid

      def initialize(axes: {}, travel: false, rapid: false, **kwargs)
        super(**kwargs)
        @axes = axes
        @travel = travel
        @rapid = rapid
      end

    end
  end
end
