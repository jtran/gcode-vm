require 'test_helper'

describe GcodeVm::RenameAxisTransformer do

  it "renames axis in linear move" do
    t = GcodeVm::RenameAxisTransformer.new(from: 'A', to: 'B')
    _(t.call('G1 X1 A2 F100')).must_equal('G1 X1 B2 F100')
    _(t.call('G1 X1 A2.0 F100')).must_equal('G1 X1 B2.0 F100')
  end

  it "renames axis in helical move" do
    t = GcodeVm::RenameAxisTransformer.new(from: 'A', to: 'B')
    _(t.call('G2 X1 Y2 G1 A3.0 F100')).must_equal('G2 X1 Y2 G1 B3.0 F100')
  end

  it "renames axis in G92" do
    t = GcodeVm::RenameAxisTransformer.new(from: 'A', to: 'B')
    _(t.call('G92 X1 A2 F100')).must_equal('G92 X1 B2 F100')
    _(t.call('G92 X1 A2.0 F100')).must_equal('G92 X1 B2.0 F100')
  end

  it "renames axis in linear move when there are G-code line numbers" do
    t = GcodeVm::RenameAxisTransformer.new(from: 'A', to: 'B')
    _(t.call('N0 G1 X1 A2 F100')).must_equal('N0 G1 X1 B2 F100')
    _(t.call('N10 G1 X1 A2.0 F100')).must_equal('N10 G1 X1 B2.0 F100')
  end

end
