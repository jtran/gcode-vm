module GcodeVm
  module Commands
    class SetPosition < AbstractCommand

      attr_accessor :axes

      def initialize(axes: {}, **kwargs)
        super(**kwargs)
        @axes = axes
      end

    end
  end
end
