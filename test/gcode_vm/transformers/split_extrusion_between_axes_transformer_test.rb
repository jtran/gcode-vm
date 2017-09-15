require 'test_helper'

describe GcodeVm::SplitExtrusionBetweenAxesTransformer do

  it "indicates that it needs an evaluator injected" do
    GcodeVm::SplitExtrusionBetweenAxesTransformer.needs.must_equal :evaluator
  end

  describe "when no evaluator is used" do
    it "splits extrusion based on absolute move" do
      t = GcodeVm::SplitExtrusionBetweenAxesTransformer.new(weight: 0.25,
                                                            from_axis: 'A',
                                                            to_axis: 'B')
      t.call('G1 A1.0').must_equal 'G1 A0.75 B0.25'
      t.call('G1 A2.0').must_equal 'G1 A1.5 B0.5'
    end

    it "splits extrusion based on absolute move using a callable" do
      t = GcodeVm::SplitExtrusionBetweenAxesTransformer.new(weight: ->(x) { 1 / x.last.to_f },
                                                            from_axis: 'A',
                                                            to_axis: 'B')
      # 0.25 weight
      t.call('G1 A1.0 ; 4').must_equal 'G1 A0.75 B0.25 ; 4'
      # 0.5 weight
      t.call('G1 A2.0 ; 2').must_equal 'G1 A1.25 B0.75 ; 2'
    end

    it "splits extrusion based on absolute move with a G92" do
      t = GcodeVm::SplitExtrusionBetweenAxesTransformer.new(weight: 0.25,
                                                            from_axis: 'A',
                                                            to_axis: 'B')
      t.call('G1 A1.0').must_equal 'G1 A0.75 B0.25'
      t.call('G92 A400').must_equal 'G92 A400.0 B400.0'
      t.call('G1 A402.0').must_equal 'G1 A401.5 B400.5'
    end
  end

  describe "when an evaluator is used" do
    let(:evaluator) {
      GcodeVm::Evaluator.new(axes: GcodeVm::Machine::AEROTECH_AXES)
    }

    let(:transformer) {
      GcodeVm::SplitExtrusionBetweenAxesTransformer.new(weight: 0.25,
                                                        from_axis: 'a',
                                                        to_axis: 'b',
                                                        evaluator: evaluator)
    }

    it "splits extrusion based on absolute move" do
      evaluator.is_absolute = true
      transformer.call('G1 a1.0').must_equal 'G1 a0.75 b0.25'
      transformer.call('G1 a2.0').must_equal 'G1 a1.5 b0.5'
    end

    it "splits extrusion based on absolute move when there are G-code line numbers" do
      evaluator.is_absolute = true
      transformer.call('N0 G1 a1.0').must_equal 'N0 G1 a0.75 b0.25'
      transformer.call('N10 G1 a2.0').must_equal 'N10 G1 a1.5 b0.5'
    end

    it "splits extrusion based on relative move" do
      evaluator.is_absolute = false
      transformer.call('G1 a1.0').must_equal 'G1 a0.75 b0.25'
      transformer.call('G1 a1.0').must_equal 'G1 a0.75 b0.25'
    end

    it "splits extrusion after G92 set position in absolute mode" do
      evaluator.is_absolute = true
      transformer.call('G1 a1.0').must_equal 'G1 a0.75 b0.25'
      transformer.call('G92 a1000.0').must_equal 'G92 a1000.0 b1000.0'
      transformer.call('G1 a1001.0').must_equal 'G1 a1000.75 b1000.25'
    end

    it "splits extrusion after G92 set position in relative mode" do
      evaluator.is_absolute = false
      transformer.call('G1 a1.0').must_equal 'G1 a0.75 b0.25'
      transformer.call('G92 a1000.0').must_equal 'G92 a1000.0 b1000.0'
      transformer.call('G1 a1.0').must_equal 'G1 a0.75 b0.25'
    end
  end

  it "doesn't output scientific notation" do
    t = GcodeVm::SplitExtrusionBetweenAxesTransformer.new(weight: 1.0e-15,
                                                          from_axis: 'A',
                                                          to_axis: 'B')
    t.call('G1 A1.0').must_equal 'G1 A1.0 B0.0'
  end

end
