require 'test_helper'

describe GcodeVm::AxisScaleTransformer do

  let(:transformer) {
    GcodeVm::AxisScaleTransformer.new(axis: 'F')
  }

  it "multiplies axis value without state" do
    transformer.multiplier = 2.0
    _(transformer.call('G0 X1 F1600')).must_equal('G0 X1 F3200.0')
    _(transformer.call('G1 X1 F100')).must_equal('G1 X1 F200.0')
    _(transformer.call('G1 X1 F1600')).must_equal('G1 X1 F3200.0')
    _(transformer.call('G2 X1 I2 J3 F1600')).must_equal('G2 X1 I2 J3 F3200.0')
    _(transformer.call('G3 X1 I2 J3 F1600')).must_equal('G3 X1 I2 J3 F3200.0')
    _(transformer.call('G92 X1 F100')).must_equal('G92 X1 F200.0')
  end

  it "doesn't output scientific notation" do
    t = GcodeVm::AxisScaleTransformer.new(axis: 'X', multiplier: 1.0e-15)
    _(t.call('G1 X1')).must_equal 'G1 X0.0'
  end

  it "multiplies axis value when there are G-code line numbers" do
    transformer.multiplier = 2.0
    _(transformer.call('N10 G0 X1 F1600')).must_equal('N10 G0 X1 F3200.0')
  end

end
