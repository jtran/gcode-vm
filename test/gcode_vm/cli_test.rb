require 'test_helper'
require Pathname.new('lib/gcode_vm/cli').expand_path(PROJECT_ROOT)

describe GcodeVm::Cli do

  it "transforms" do
    input = StringIO.new
    input.string = "G1 X1 F1000\nG1 Y2"
    output = StringIO.new
    cli = GcodeVm::Cli.new(transform_file: Pathname.new('test/data/simple_transform.yml').expand_path(PROJECT_ROOT),
                           quiet: true)

    cli.main(read_stdin: false, stdin_enum: input.each_line, sink_io: output)

    output.string.must_equal "G1 X1 F1500.0\nG1 Y2\n"
  end

  it "transforms using evaluator dependency" do
    input = StringIO.new
    input.string = "G1 b1\nG1 b2"
    output = StringIO.new
    cli = GcodeVm::Cli.new(transform_file: Pathname.new('test/data/extrusion_transform.yml').expand_path(PROJECT_ROOT),
                           quiet: true)

    cli.main(read_stdin: false, stdin_enum: input.each_line, sink_io: output)

    output.string.must_equal "G1 b2.0\nG1 b4.0\n"
  end

  it "outputs extra new line when reaching end of input in interactive mode" do
    input = StringIO.new
    input.string = "G1 X1 F1000\nG1 Y2"
    output = StringIO.new
    cli = GcodeVm::Cli.new(transform_file: Pathname.new('test/data/simple_transform.yml').expand_path(PROJECT_ROOT),
                           quiet: false)

    cli.main(read_stdin: false, stdin_enum: input.each_line, sink_io: output)

    output.string.must_equal "G1 X1 F1500.0\nG1 Y2\n\n"
  end

  it "stops transforming after reaching exit in interactive mode" do
    input = StringIO.new
    input.string = "G1 X1 F1000\nexit\nG1 Y2"
    output = StringIO.new
    cli = GcodeVm::Cli.new(transform_file: Pathname.new('test/data/simple_transform.yml').expand_path(PROJECT_ROOT),
                           quiet: false)

    cli.main(read_stdin: false, stdin_enum: input.each_line, sink_io: output)

    output.string.must_equal "G1 X1 F1500.0\n"
  end

  it "prints transform list" do
    input = StringIO.new
    input.string = ''
    output = StringIO.new
    cli = GcodeVm::Cli.new(list: true)

    cli.main(read_stdin: false, stdin_enum: input.each_line, sink_io: output)

    output.string.must_match /axis_translate/
    output.string.must_match /axis_scale/
  end

end
