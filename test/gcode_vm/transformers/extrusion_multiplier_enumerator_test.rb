require 'test_helper'

describe GcodeVm::ExtrusionMultiplierEnumerator do

  let(:enum) {
    GcodeVm::ExtrusionMultiplierEnumerator.new(axis: 'Z')
  }

  it "indicates that it needs an evaluator injected" do
    _(GcodeVm::ExtrusionMultiplierEnumerator.needs).must_equal :evaluator
  end

  describe "when no evaluator is used" do
    it "multiplies based on absolute move" do
      enum.source_enum = ['G1 X1 Z10', 'G1 X2 Z11'].each
      _(enum.next).must_equal('G1 X1 Z10.0')

      enum.multiplier = 2.0
      _(enum.next).must_equal('G1 X2 Z12.0')
    end
  end

  describe "when evaluator is used" do
    let(:evaluator) { GcodeVm::Evaluator.new }

    let(:enum) {
      GcodeVm::ExtrusionMultiplierEnumerator.new(axis: 'Z',
                                                 multiplier: 2.0,
                                                 evaluator: evaluator)
    }

    it "multiplies based on absolute move" do
      evaluator.is_absolute = true
      enum.source_enum = ['G1 X1 Z10', 'G1 X2 Z11'].each

      _(enum.next).must_equal 'G1 X1 Z20.0'
      _(enum.next).must_equal 'G1 X2 Z22.0'
    end

    it "multiplies based on absolute move when there are G-code line numbers" do
      evaluator.is_absolute = true
      enum.source_enum = ['N0 G1 X1 Z10', 'N10 G1 X2 Z11'].each

      _(enum.next).must_equal 'N0 G1 X1 Z20.0'
      _(enum.next).must_equal 'N10 G1 X2 Z22.0'
    end

    it "multiplies based on relative move" do
      evaluator.is_absolute = false
      enum.source_enum = ['G1 X1 Z10', 'G1 X2 Z21'].each

      _(enum.next).must_equal 'G1 X1 Z20.0'
      _(enum.next).must_equal 'G1 X2 Z42.0'
    end

    it "multiplies after a G92 set position in absolute mode" do
      evaluator.is_absolute = true
      enum.source_enum = ['G1 X1 Z10', 'G92 Z1000', 'G1 X2 Z1001'].each

      _(enum.next).must_equal 'G1 X1 Z20.0'
      _(enum.next).must_equal 'G92 Z1000'
      _(enum.next).must_equal 'G1 X2 Z1002.0'
    end

    it "multiplies after a G92 set position in relative mode" do
      evaluator.is_absolute = false
      enum.source_enum = ['G1 X1 Z10', 'G92 Z1000', 'G1 X2 Z21'].each

      _(enum.next).must_equal 'G1 X1 Z20.0'
      _(enum.next).must_equal 'G92 Z1000'
      _(enum.next).must_equal 'G1 X2 Z42.0'
    end

    describe "when using an axis configured as always relative" do
      let(:enum) {
        GcodeVm::ExtrusionMultiplierEnumerator.new(axis: 'E',
                                                   multiplier: 2.0,
                                                   evaluator: evaluator)
      }

      it "multiplies based on relative move in absolute mode" do
        evaluator.is_absolute = true
        enum.source_enum = ['G1 X1 E10', 'G1 X2 E2'].each

        _(enum.next).must_equal 'G1 X1 E20.0'
        _(enum.next).must_equal 'G1 X2 E4.0'
      end
    end
  end

  it "multiplies based on absolute move with a G92" do
    enum.source_enum = ['G1 X1 Z10', 'G1 X2 Z11', 'G92 Z400', 'G1 X2 Z421'].each

    _(enum.next).must_equal 'G1 X1 Z10.0'

    enum.multiplier = 2.0
    _(enum.next).must_equal 'G1 X2 Z12.0'
    _(enum.next).must_equal 'G92 Z400'
    _(enum.next).must_equal 'G1 X2 Z442.0'
  end

  it "only multiplies when condition passes" do
    condition = GcodeVm::MatchCondition.new(pattern: /F100/)
    enum = GcodeVm::ExtrusionMultiplierEnumerator.new(axis: 'Z',
                                                      condition: condition,
                                                      multiplier: 2.0)
    enum.source_enum = ['G1 X2 Z11', 'G1 X2 Z12 F100'].each
    _(enum.next).must_equal 'G1 X2 Z11.0'
    _(enum.next).must_equal 'G1 X2 Z13.0 F100'
  end

  it "doesn't multiply when if_matches fails to match" do
    expect {
      enum = GcodeVm::ExtrusionMultiplierEnumerator.new(axis: 'Z',
                                                        if_matches: /F100/,
                                                        multiplier: 2.0)
      enum.source_enum = ['G1 X2 Z11', 'G1 X2 Z12 F100'].each
      _(enum.next).must_equal 'G1 X2 Z11.0'
      _(enum.next).must_equal 'G1 X2 Z13.0 F100'
    }.must_output(nil, "DEPRECATION: using \"if_matches\" in a transform file is deprecated; use \"if\" instead\n")
  end

  it "doesn't output scientific notation after small accumulated value" do
    enum = GcodeVm::ExtrusionMultiplierEnumerator.new(axis: 'Z',
                                                      initial_value: -5.0e-16,
                                                      multiplier: 2.0)
    enum.source_enum = ['G1 X1 Z0'].each
    _(enum.next).must_equal 'G1 X1 Z0.0'
  end

  it "disallows using both condition and if_matches" do
    condition = GcodeVm::MatchCondition.new(pattern: /bar/)
    expect {
      GcodeVm::ExtrusionMultiplierEnumerator.new(axis: 'Z',
                                                 if_matches: /foo/,
                                                 condition: condition)
    }.must_raise(ArgumentError)
  end

end
