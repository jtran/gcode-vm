require 'test_helper'

describe GcodeVm::GcodeFormatter do

  it "converts commands to G-code" do
    _(GcodeVm::Commands::Move.new(axes: { 'X' => 10.0, 'Y' => 20.0 }).to_gcode).must_equal 'G1 X10.0 Y20.0'
    _(GcodeVm::Commands::SetPosition.new(axes: { 'X' => 10.0, 'Y' => 20.0 }).to_gcode).must_equal 'G92 X10.0 Y20.0'
    _(GcodeVm::Commands::Arc.new(ccw: false, axes: { 'X' => 10.0, 'Y' => 20.0, 'I' => 1.0, 'J' => 2.0 }).to_gcode).must_equal 'G2 X10.0 Y20.0 I1.0 J2.0'
    _(GcodeVm::Commands::Arc.new(ccw: true, axes: { 'X' => 10.0, 'Y' => 20.0, 'I' => 1.0, 'J' => 2.0 }).to_gcode).must_equal 'G3 X10.0 Y20.0 I1.0 J2.0'
    _(GcodeVm::Commands::Dwell.new(seconds: 1.5).to_gcode).must_equal 'G4 P1.5'
    _(GcodeVm::Commands::Comment.new(comment: 'foo').to_gcode).must_equal '; foo'
    _(GcodeVm::Commands::Literal.new(gcode: 'M110').to_gcode).must_equal 'M110'
  end

  it "never outputs in scientific notation" do
    _(GcodeVm::Commands::Move.new(axes: { 'X' => 3.0e16 }).to_gcode).must_equal 'G1 X30000000000000000.0'
  end

  it "rounds output to precision" do
    _(GcodeVm::Commands::Move.new(axes: { 'X' => 3.0e-16 }).to_gcode).must_equal 'G1 X0.0'
    _(GcodeVm::Commands::Move.new(axes: { 'X' => 0.12345691 }).to_gcode).must_equal 'G1 X0.123457'
  end

end
