require 'test_helper'

describe GcodeVm::ConvertToRelativeTransformer do

  let(:transformer) {
    GcodeVm::ConvertToRelativeTransformer.new(axis: 'E')
  }

  it "converts to relative based on absolute extrusion" do
    _(transformer.call('G1 X1 E10')).must_equal('G1 X1 E10.0')
    _(transformer.call('G1 X2 E11.5')).must_equal('G1 X2 E1.5')
  end

  it "converts to relative based on absolute extrusion with G-code line numbers" do
    _(transformer.call('N0 G1 X1 E10')).must_equal('N0 G1 X1 E10.0')
    _(transformer.call('N10 G1 X2 E11.5')).must_equal('N10 G1 X2 E1.5')
  end

  it "converts to relative based on absolute extrusion with a G92" do
    _(transformer.call('G1 X1 E10')).must_equal('G1 X1 E10.0')
    _(transformer.call('G92 E400')).must_equal('G92 E400')
    _(transformer.call('G1 X2 E401.5')).must_equal('G1 X2 E1.5')
  end

end
