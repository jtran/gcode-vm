require 'test_helper'
require Pathname.new('lib/gcode_vm/cli_common').expand_path(PROJECT_ROOT)

describe GcodeVm::FileFormatHelper do

  it "instantiates G-code toolpath file based on file extension" do
    tp_file = GcodeVm::FileFormatHelper.toolpath_file('foo.gcode', nil)
    _(tp_file).must_be_instance_of GcodeVm::GcodeToolpathFile
    _(tp_file.filename).must_equal 'foo.gcode'
  end

  it "instantiates G-code toolpath file based on explicit format" do
    tp_file = GcodeVm::FileFormatHelper.toolpath_file('foo.toolpath', 'gcode')
    _(tp_file).must_be_instance_of GcodeVm::GcodeToolpathFile
    _(tp_file.filename).must_equal 'foo.toolpath'
  end

  it "instantiates custom toolpath file based on file extension" do
    called_with = nil
    GcodeVm::FileFormatHelper.register_file_format(:my_custom_format, '.custom') do |filename|
      called_with = filename
      # Normally you would return the custom toolpath file instance here.
      42
    end
    tp_file = GcodeVm::FileFormatHelper.toolpath_file('foo.custom', nil)
    _(tp_file).must_equal 42
    _(called_with).must_equal 'foo.custom'
  end

  it "instantiates custom toolpath file based on explicit format" do
    called_with = nil
    GcodeVm::FileFormatHelper.register_file_format(:my_custom_format, '.custom') do |filename|
      called_with = filename
      # Normally you would return the custom toolpath file instance here.
      42
    end
    tp_file = GcodeVm::FileFormatHelper.toolpath_file('foo.gcode', :my_custom_format)
    _(tp_file).must_equal 42
    _(called_with).must_equal 'foo.gcode'
  end

  it "raises if given an unknown toolpath format when trying to instantiate file" do
    expect {
      GcodeVm::FileFormatHelper.toolpath_file('foo.gcode', 'non-existent')
    }.must_raise(RuntimeError)
  end

  it "defaults to gcode if no toolpath format can be inferred" do
    _(GcodeVm::FileFormatHelper.canonical_toolpath_format('no-extension', nil)).must_equal :gcode
    _(GcodeVm::FileFormatHelper.canonical_toolpath_format(nil, nil)).must_equal :gcode
  end

end
