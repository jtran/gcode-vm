module GcodeVm
  module Commands
    class Literal < AbstractCommand

      attr_accessor :passthrough

      def initialize(passthrough: false, **kwargs)
        super(**kwargs)
        @passthrough = passthrough
      end

    end
  end
end
