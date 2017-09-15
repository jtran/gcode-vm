require 'test_helper'

describe GcodeVm::DSL do

  it "builds move" do
    dsl = GcodeVm::DSL.new
    dsl.move(X: 10.0, Y: 20.0)
    dsl.commands[0].must_equal GcodeVm::Commands::Move.new(axes: { X: 10.0, Y: 20.0 })
  end

  it "builds arc" do
    dsl = GcodeVm::DSL.new
    dsl.arc(ccw: false, X: 10.0, Y: 20.0, I: 1.0, J: 2.0)
    dsl.commands[0].must_equal GcodeVm::Commands::Arc.new(axes: { X: 10.0, Y: 20.0, I: 1.0, J: 2.0 }, ccw: false)
  end

  it "builds set position" do
    dsl = GcodeVm::DSL.new
    dsl.set_position(X: 10.0, Y: 20.0)
    dsl.commands[0].must_equal GcodeVm::Commands::SetPosition.new(axes: { X: 10.0, Y: 20.0 })
  end

  it "has a nice DSL for G-code" do
    dsl = GcodeVm::DSL.new
    dsl.instance_eval do
      def tool_on_and_wait
        literal 'M109 S220'
      end

      def tool_off
        literal 'M104 S0'
      end

      home :X, :Y
      absolute
      tool_on_and_wait

      rapid X: 0, Y: 0, Z: 1.9, F: 12000
      incremental do
        comment "Two layers of a square."
        2.times do |i|
          comment "Layer #{i}"
          move X:  10, E: 2
          move Y:  10, E: 2
          move X: -10, E: 2
          move Y: -10, E: 2
          rapid Z: 1.9
        end
      end

      comment "Lift up nozzle."
      rapid Z: 30
      comment "Clean up."
      tool_off
      absolute
    end

    dsl.commands.map {|c| "#{c.to_gcode}\n" }.join.must_equal <<-EOS
G28 X Y
G90
M109 S220
G0 X0.0 Y0.0 Z1.9 F12000.0
G91
; Two layers of a square.
; Layer 0
G1 X10.0 E2.0
G1 Y10.0 E2.0
G1 X-10.0 E2.0
G1 Y-10.0 E2.0
G0 Z1.9
; Layer 1
G1 X10.0 E2.0
G1 Y10.0 E2.0
G1 X-10.0 E2.0
G1 Y-10.0 E2.0
G0 Z1.9
; Lift up nozzle.
G0 Z30.0
; Clean up.
M104 S0
G90
    EOS
  end

end
