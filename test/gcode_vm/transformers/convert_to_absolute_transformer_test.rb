require 'test_helper'

describe GcodeVm::ConvertToAbsoluteTransformer do

  let(:transformer) {
    GcodeVm::ConvertToAbsoluteTransformer.new(axis: 'E')
  }

  it "converts to absolute based on relative extrusion" do
    _(transformer.call('G1 X1 E10')).must_equal('G1 X1 E10.0')
    _(transformer.call('G1 X2 E1.5')).must_equal('G1 X2 E11.5')
  end

  it "converts to absolute based on relative extrusion with G-code line numbers" do
    _(transformer.call('N0 G1 X1 E10')).must_equal('N0 G1 X1 E10.0')
    _(transformer.call('N10 G1 X2 E1.5')).must_equal('N10 G1 X2 E11.5')
  end

  it "converts to absolute based on relative extrusion with a G92" do
    _(transformer.call('G1 X1 E10')).must_equal('G1 X1 E10.0')
    _(transformer.call('G92 E400')).must_equal('G92 E400')
    _(transformer.call('G1 X2 E1.5')).must_equal('G1 X2 E401.5')
  end

  it "doesn't output scientific notation" do
    t = GcodeVm::ConvertToAbsoluteTransformer.new(axis: 'E', initial_value: -1.0e-15)
    _(t.call('G1 X1 E0')).must_equal('G1 X1 E0.0')
  end

end
