require 'test_helper'

describe GcodeVm::Evaluator do

  let(:evaluator) { GcodeVm::Evaluator.new }

  it "evaluates linear move in absolute mode" do
    cmd = GcodeVm::Commands.parse('G1 X10.0 Y20.0 Z-30.0')
    evaluator.is_absolute = true
    evaluator.evaluate(cmd)

    _(evaluator.position[:X]).must_equal 10.0
    _(evaluator.position[:Y]).must_equal 20.0
    _(evaluator.position[:Z]).must_equal -30.0
  end

  it "evaluates linear move in relative mode" do
    cmd = GcodeVm::Commands.parse('G1 X10.0 Y20.0 Z-30.0')
    evaluator.is_absolute = false
    evaluator.position[:X] = 100.0
    evaluator.position[:Y] = 200.0
    evaluator.position[:Z] = 300.0

    evaluator.evaluate(cmd)

    _(evaluator.position[:X]).must_equal 110.0
    _(evaluator.position[:Y]).must_equal 220.0
    _(evaluator.position[:Z]).must_equal 270.0
  end

  it "evaluates feedrate in relative mode" do
    cmd = GcodeVm::Commands.parse('G1 F3000.0')
    evaluator.is_absolute = false
    evaluator.position[:F] = 10.0

    evaluator.evaluate(cmd)

    _(evaluator.position[:F]).must_equal 3000.0
  end

  it "evaluates relative extrusion in absolute mode" do
    cmd = GcodeVm::Commands.parse('G1 E42.0')
    evaluator.is_absolute = true
    evaluator.position[:E] = 1000.0

    evaluator.evaluate(cmd)

    _(evaluator.position[:E]).must_equal 1042.0
  end

  it "evaluates clockwise arc move with explicit endpoint" do
    cmd = GcodeVm::Commands.parse('G2 X10.0 Y20.0 I1.0 J2.0')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 10.0
    _(evaluator.position[:Y]).must_equal 20.0
  end

  it "evaluates counter-clockwise arc move with explicit endpoint" do
    cmd = GcodeVm::Commands.parse('G3 X10.0 Y20.0 I1.0 J2.0')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 10.0
    _(evaluator.position[:Y]).must_equal 20.0
  end

  it "evaluates clockwise arc move without endpoint" do
    cmd = GcodeVm::Commands.parse('G2 I1.0 J2.0')
    evaluator.evaluate(cmd)
    # End point is the same as start (a full circle), so no change.
    _(evaluator.position[:X]).must_equal 0.0
    _(evaluator.position[:Y]).must_equal 0.0
  end

  it "evaluates counter-clockwise arc move without endpoint" do
    cmd = GcodeVm::Commands.parse('G3 I1.0 J2.0')
    evaluator.evaluate(cmd)
    # End point is the same as start (a full circle), so no change.
    _(evaluator.position[:X]).must_equal 0.0
    _(evaluator.position[:Y]).must_equal 0.0
  end

  it "evaluates clockwise helix move with explicit endpoint" do
    cmd = GcodeVm::Commands.parse('G2 X10.0 Y20.0 I1.0 J2.0 G1 Z3.0')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 10.0
    _(evaluator.position[:Y]).must_equal 20.0
    _(evaluator.position[:Z]).must_equal 3.0
  end

  it "evaluates counter-clockwise helix move with explicit endpoint" do
    cmd = GcodeVm::Commands.parse('G3 X10.0 Y20.0 I1.0 J2.0 G1 Z3.0')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 10.0
    _(evaluator.position[:Y]).must_equal 20.0
    _(evaluator.position[:Z]).must_equal 3.0
  end

  it "evaluates dwell" do
    cmd = GcodeVm::Commands.parse('G4 P1.0')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 0.0
    _(evaluator.position[:Y]).must_equal 0.0
  end

  it "evaluates home command" do
    cmd = GcodeVm::Commands.parse('G28')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 0.0
    _(evaluator.position[:Y]).must_equal 0.0
  end

  it "evaluates comment" do
    cmd = GcodeVm::Commands.parse('; foo')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 0.0
    _(evaluator.position[:Y]).must_equal 0.0
  end

  it "evalutes literal" do
    cmd = GcodeVm::Commands::Literal.new(gcode: 'M110')
    evaluator.evaluate(cmd)
    _(evaluator.position[:X]).must_equal 0.0
    _(evaluator.position[:Y]).must_equal 0.0
  end

  it "ignores evaluation of unknown axes in linear move" do
    cmd = GcodeVm::Commands.parse('G1 Y42.0 B10.0 C20.0')
    evaluator.is_absolute = true
    evaluator.evaluate(cmd)

    _(evaluator.position[:X]).must_equal 0.0
    _(evaluator.position[:Y]).must_equal 42.0
    _(evaluator.position[:Z]).must_equal 0.0
  end

  it "evaluates absolute command" do
    cmd = GcodeVm::Commands.parse('G90')
    evaluator.is_absolute = false
    evaluator.evaluate(cmd)

    _(evaluator.absolute?).must_equal true
    _(evaluator.relative?).must_equal false
  end

  it "evaluates relative command" do
    cmd = GcodeVm::Commands.parse('G91')
    evaluator.is_absolute = true
    evaluator.evaluate(cmd)

    _(evaluator.absolute?).must_equal false
    _(evaluator.relative?).must_equal true
  end

  it "evaluates set position command" do
    cmd = GcodeVm::Commands.parse('G92 X7.0')
    evaluator.position[:X] = 4.0
    # Pre-condition.
    _(evaluator.offset[:X]).must_equal 0.0
    _(evaluator.physical_position(:X)).must_equal 4.0

    evaluator.evaluate(cmd)

    _(evaluator.offset[:X]).must_equal -3.0
    _(evaluator.offset[:Y]).must_equal 0.0
    _(evaluator.position[:X]).must_equal 7.0
    _(evaluator.physical_position(:X)).must_equal 4.0

    cmd = GcodeVm::Commands.parse('G92 X9.0')
    evaluator.evaluate(cmd)

    _(evaluator.offset[:X]).must_equal -5.0
    _(evaluator.offset[:Y]).must_equal 0.0
    _(evaluator.position[:X]).must_equal 9.0
    _(evaluator.physical_position(:X)).must_equal 4.0
  end

  it "determines if an axis is in absolute mode" do
    evaluator.is_absolute = true
    _(evaluator.axis_absolute?(:X)).must_equal true
    _(evaluator.axis_absolute?(:E)).must_equal false
    _(evaluator.axis_absolute?(:F)).must_equal true
    evaluator.is_absolute = false
    _(evaluator.axis_absolute?(:X)).must_equal false
    _(evaluator.axis_absolute?(:E)).must_equal false
    _(evaluator.axis_absolute?(:F)).must_equal true
  end

  it "determines if an axis is in absolute mode using string arguments" do
    evaluator.is_absolute = true
    _(evaluator.axis_absolute?('X')).must_equal true
    _(evaluator.axis_absolute?('E')).must_equal false
    _(evaluator.axis_absolute?('F')).must_equal true
    evaluator.is_absolute = false
    _(evaluator.axis_absolute?('X')).must_equal false
    _(evaluator.axis_absolute?('E')).must_equal false
    _(evaluator.axis_absolute?('F')).must_equal true
  end

  it "determines if an axis is in absolute mode when the axis hasn't been configured" do
    evaluator.is_absolute = true
    _(evaluator.axis_absolute?('non existent')).must_equal true
    evaluator.is_absolute = false
    _(evaluator.axis_absolute?('non existent')).must_equal false
  end

  it "raises when getting absolute mode of a nil axis" do
    _(proc {
      evaluator.axis_absolute?(nil)
    }).must_raise(ArgumentError)
  end

end
