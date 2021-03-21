require 'test_helper'

describe GcodeVm::SplitMoveEnumerator do

  it "indicates that it needs an evaluator injected" do
    _(GcodeVm::SplitMoveEnumerator.needs).must_equal :evaluator
  end

  it "doesn't split when equal to max distance" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['G1 X1.0 F1000'].each
    _(enum.to_a).must_equal ['G1 X1.0 F1000']
  end

  it "doesn't split when max distance is infinity" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: Float::INFINITY)
    enum.source_enum = ['G1 X1.0 F1000'].each
    _(enum.to_a).must_equal ['G1 X1.0 F1000']
  end

  it "raises when max distance is 0" do
    expect {
      GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 0.0)
    }.must_raise(ArgumentError)
  end

  it "doesn't modify arcs or G92" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['G2 X100.0 I22 J33 F1000'].each
    _(enum.to_a).must_equal ['G2 X100.0 I22 J33 F1000']
    enum.source_enum = ['G92 X100.0'].each
    _(enum.to_a).must_equal ['G92 X100.0']
  end

  it "splits based on max distance" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['G1 X2.0 F1000'].each
    _(enum.to_a).must_equal ['G1 X1.0 F1000', 'G1 X2.0 F1000']
  end

  it "splits based on max distance when there are G-code line numbers" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['N10 G1 X2.0 F1000'].each
    _(enum.to_a).must_equal ['N10 G1 X1.0 F1000', 'N10 G1 X2.0 F1000']
  end

  it "splits G0 based on max distance and converts to G1" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['G0 X2.0 F1000'].each
    _(enum.to_a).must_equal ['G1 X1.0 F1000', 'G1 X2.0 F1000']
  end

  it "ignores distance of non-distance axes" do
    # Using Y as distance.
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['G1 X1.0 Y1 F1000'].each
    _(enum.to_a).must_equal ['G1 X0.5 Y0.5 F1000', 'G1 X1.0 Y1.0 F1000']
    # Not using Y as distance.
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], distance_axes: [:X, :Z], max_distance: 1.0)
    enum.source_enum = ['G1 X2.0 Y1 F1000'].each
    _(enum.to_a).must_equal ['G1 X1.0 Y0.5 F1000', 'G1 X2.0 Y1.0 F1000']
  end

  it "splits using current position of the evaluator in absolute mode" do
    evaluator = GcodeVm::Evaluator.new
    evaluator.is_absolute = true
    evaluator.position[:X] = 100.0
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0, evaluator: evaluator)
    enum.source_enum = ['G1 X102.0 F1000'].each
    _(enum.to_a).must_equal ['G1 X101.0 F1000', 'G1 X102.0 F1000']
  end

  it "splits using current position of the evaluator in incremental mode" do
    evaluator = GcodeVm::Evaluator.new
    evaluator.is_absolute = false
    evaluator.position[:X] = 100.0
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0, evaluator: evaluator)
    enum.source_enum = ['G1 X2.0 F1000'].each
    _(enum.to_a).must_equal ['G1 X1.0 F1000', 'G1 X2.0 F1000']
  end

  it "splits based on max distance using multiple axes" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['G1 X1.0 Y2.0 E1 F1000'].each
    _(enum.to_a).must_equal ['G1 X0.333333 Y0.666667 E0.333333 F1000', 'G1 X0.666667 Y1.333333 E0.666667 F1000', 'G1 X1.0 Y2.0 E1.0 F1000']
    enum.source_enum = ['G1 X3.0 Y4.0 F1000'].each
    _(enum.to_a).must_equal ['G1 X0.6 Y0.8 F1000', 'G1 X1.2 Y1.6 F1000', 'G1 X1.8 Y2.4 F1000', 'G1 X2.4 Y3.2 F1000', 'G1 X3.0 Y4.0 F1000']
  end

  it "allows nil and other unrecognized strings to pass through" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
    enum.source_enum = ['foo', nil, ''].each
    _(enum.to_a).must_equal ['foo', nil, '']
  end

  it "splits and transforms" do
    enum = GcodeVm::SplitMoveEnumerator.new(axes: [:X, :Y, :Z, :E], max_distance: 1.0)
      .pipe &:upcase
    enum.source_enum = ['G1 X2.0 F1000 ; some comment'].each
    _(enum.to_a).must_equal ['G1 X1.0 F1000 ; SOME COMMENT', 'G1 X2.0 F1000 ; SOME COMMENT']
  end

end
