require 'test_helper'

describe GcodeVm::MultiAxisTransformer do

  let(:transformer) {
    GcodeVm::MultiAxisTransformer.new(axes: %w[c d],
                                      transformer_factory: GcodeVm::AxisTranslateTransformer)
  }

  it "allows access to a single axis transformer" do
    transformer.call('G1 X1 c10 d100').must_equal('G1 X1 c10.0 d100.0')

    transformer.axis('c').amount = 2.0
    transformer.call('G1 X2 c10 d100').must_equal('G1 X2 c12.0 d100.0')
  end

  it "passes keyword arguments to factory" do
    gcode_formatter = GcodeVm::GcodeFormatter.new
    t = GcodeVm::MultiAxisTransformer.new(axes: %w[c],
                                          transformer_factory: GcodeVm::AxisScaleTransformer,
                                          factory_kwargs: { gcode_formatter: gcode_formatter })
    t.axis('c').gcode_formatter.must_be_same_as gcode_formatter
  end

end
