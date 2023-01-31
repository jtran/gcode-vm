require 'test_helper'

describe GcodeVm::Commands do

  if RUBY_VERSION < '3.1'
    def yaml_load(s)
      YAML.load(s)
    end
  else
    def yaml_load(s)
      YAML.load(s, permitted_classes: GcodeVm::Commands.yaml_safe_commands)
    end
  end

  it "round-trips to YAML" do
    cmd = GcodeVm::Commands::Move.new
    cmd.axes['X'] = 1.5
    cmd.gcode = 'G1 X1.5'

    _(yaml_load(YAML.dump(cmd))).must_equal cmd
  end

  it "parses from YAML" do
    s = <<-EOS
%YAML 1.1
---
!ruby/object:GcodeVm::Commands::Move
axes:
  X: 90.20100000000001
  b: 49.53281274186602
gcode: G1 X90.201 b49.532813
    EOS

    obj = yaml_load(s)
    _(obj).must_be_instance_of GcodeVm::Commands::Move
  end

  it "serializes to YAML" do
    cmd = GcodeVm::Commands::Move.new
    cmd.axes['X'] = 1.5
    cmd.gcode = 'G1 X1.5'

    yaml = YAML.dump(cmd)
    _(yaml).must_equal <<-EOS
--- !ruby/object:GcodeVm::Commands::Move
axes:
  X: 1.5
gcode: G1 X1.5
rapid: false
travel: false
    EOS
  end

  it "round-trips to YAML with line number" do
    cmd = GcodeVm::Commands::Move.new
    cmd.axes['X'] = 1.5
    cmd.gcode = 'N23 G1 X1.5'
    cmd.line_number = 23

    _(yaml_load(YAML.dump(cmd))).must_equal cmd
  end

  it "serializes to YAML with line number" do
    cmd = GcodeVm::Commands::Move.new
    cmd.axes['X'] = 1.5
    cmd.gcode = 'N23 G1 X1.5'
    cmd.line_number = 23

    yaml = YAML.dump(cmd)
    _(yaml).must_equal <<-EOS
--- !ruby/object:GcodeVm::Commands::Move
axes:
  X: 1.5
gcode: N23 G1 X1.5
line_number: 23
rapid: false
travel: false
    EOS
  end

end
