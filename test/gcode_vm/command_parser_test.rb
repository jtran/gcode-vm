require 'test_helper'

describe GcodeVm::CommandParser do

  let(:parser) { GcodeVm::CommandParser.new }

  it "parses individual commands" do
    # Move
    parser.parse_line('G0 X1 Y2').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 1, 'Y' => 2 }, rapid: true, gcode: 'G0 X1 Y2')
    parser.parse_line('G1 X1 Y2.0').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 1, 'Y' => 2.0 }, gcode: 'G1 X1 Y2.0')
    # Arc
    parser.parse_line('G2 X1 Y2.0 I3 J4').must_equal GcodeVm::Commands::Arc.new(axes: { 'X' => 1, 'Y' => 2.0, 'I' => 3, 'J' => 4 }, :ccw => false, gcode: 'G2 X1 Y2.0 I3 J4')
    parser.parse_line('G3 X1 Y2.0 I3 J4').must_equal GcodeVm::Commands::Arc.new(axes: { 'X' => 1, 'Y' => 2.0, 'I' => 3, 'J' => 4 }, :ccw => true, gcode: 'G3 X1 Y2.0 I3 J4')
    # Comments
    parser.parse_line('G1 X1 Y2.0 ; comment').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 1, 'Y' => 2.0 }, comment: ' comment', gcode: 'G1 X1 Y2.0 ; comment')
    parser.parse_line('G1 X1 Y2.0 (comment)').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 1, 'Y' => 2.0 }, comment: 'comment', gcode: 'G1 X1 Y2.0 (comment)')
    parser.parse_line('G1 X1 Y2.0 (comment1) (comment2)').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 1, 'Y' => 2.0 }, comment: 'comment1 / comment2', gcode: 'G1 X1 Y2.0 (comment1) (comment2)')
    parser.parse_line('G1 X1 (comment1) Y2.0 (comment2)').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 1, 'Y' => 2.0 }, comment: 'comment1 / comment2', gcode: 'G1 X1 (comment1) Y2.0 (comment2)')
    # Dwell
    parser.parse_line('G4 P2.6').must_equal GcodeVm::Commands::Dwell.new(words: { 'P' => 2.6 }, gcode: 'G4 P2.6')
    parser.parse_line('G4 S2').must_equal GcodeVm::Commands::Dwell.new(words: { 'S' => 2 }, gcode: 'G4 S2')
    parser.parse_line('G4 P2.6 ; hello').must_equal GcodeVm::Commands::Dwell.new(words: { 'P' => 2.6 }, comment: ' hello', gcode: 'G4 P2.6 ; hello')
    # Home
    parser.parse_line('G28').must_equal GcodeVm::Commands::Home.new(gcode: 'G28')
    parser.parse_line('G28 X Y').must_equal GcodeVm::Commands::Home.new(axes: { 'X' => nil, 'Y' => nil }, gcode: 'G28 X Y')
    # Absolute
    parser.parse_line('G90').must_equal GcodeVm::Commands::Absolute.new(gcode: 'G90')
    # Relative
    parser.parse_line('G91').must_equal GcodeVm::Commands::Incremental.new(gcode: 'G91')
    # Set position
    parser.parse_line('G92 X1 Y2.0').must_equal GcodeVm::Commands::SetPosition.new(axes: { 'X' => 1, 'Y' => 2.0 }, gcode: 'G92 X1 Y2.0')
    # Unknown
    parser.parse_line('M110').must_equal GcodeVm::Commands::Unknown.new(gcode: 'M110')
    # Leading spaces
    parser.parse_line('   G1 X2').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 2 }, gcode: '   G1 X2')
  end

  it "parses commands with line number" do
    parser.parse_line('N0 G1 X2 Y3').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 2, 'Y' => 3 }, line_number: 0, gcode: 'N0 G1 X2 Y3')
    parser.parse_line('N000 G1 X2 Y3').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 2, 'Y' => 3 }, line_number: 0, gcode: 'N000 G1 X2 Y3')
    parser.parse_line('N010 G1 X2 Y3').must_equal GcodeVm::Commands::Move.new(axes: { 'X' => 2, 'Y' => 3 }, line_number: 10, gcode: 'N010 G1 X2 Y3')
    parser.parse_line('N110').must_equal GcodeVm::Commands::Unknown.new(line_number: 110, gcode: 'N110')
  end

end
