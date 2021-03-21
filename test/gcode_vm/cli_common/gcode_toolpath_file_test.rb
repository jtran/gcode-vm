require 'test_helper'
require Pathname.new('lib/gcode_vm/cli_common').expand_path(PROJECT_ROOT)

describe GcodeVm::GcodeToolpathFile do

  let(:toolpath_file) {
    GcodeVm::GcodeToolpathFile.new(Pathname.new('test/data/square.gcode').expand_path(PROJECT_ROOT))
  }

  it "counts commands" do
    _(toolpath_file.count_commands).must_equal 9
  end

  it "returns lazy enumerator of commands" do
    begin
      enum = toolpath_file.lazy_commands_enum
      _(enum).must_be_kind_of Enumerator::Lazy
      _(enum.take(1).first).must_match /\AG[\d]/
    ensure
      toolpath_file.close
    end
  end

  it "yields lazy enumerator of commands" do
    asserted = false
    toolpath_file.lazy_commands_enum do |enum|
      _(enum).must_be_instance_of Enumerator::Lazy
      asserted = true
    end

    _(asserted).must_equal true
  end

end
