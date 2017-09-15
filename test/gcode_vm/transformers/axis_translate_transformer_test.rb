require 'test_helper'

describe GcodeVm::AxisTranslateTransformer do

  let(:transformer) {
    GcodeVm::AxisTranslateTransformer.new(axis: 'Z')
  }

  it "translates axis" do
    transformer.call('G1 X1 Z10').must_equal('G1 X1 Z10.0')

    transformer.amount = 2.5
    transformer.call('G1 X2 Z10').must_equal('G1 X2 Z12.5')
    transformer.call('G92 X2 Z10').must_equal('G92 X2 Z12.5')
  end

  it "translates axis when there are G-code line numbers" do
    transformer.call('N10 G1 X1 Z10').must_equal('N10 G1 X1 Z10.0')

    transformer.amount = 2.5
    transformer.call('N0 G1 X2 Z10').must_equal('N0 G1 X2 Z12.5')
    transformer.call('N10 G92 X2 Z10').must_equal('N10 G92 X2 Z12.5')
  end

end
