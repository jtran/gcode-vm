require 'test_helper'

describe GcodeVm::FillPositionTransformer do

  let(:evaluator) { GcodeVm::Evaluator.new }

  it "indicates that it needs an evaluator injected" do
    GcodeVm::FillPositionTransformer.needs.must_equal :evaluator
  end

  it "fills current feedrate" do
    t = GcodeVm::FillPositionTransformer.new(axis: 'F', evaluator: evaluator)
    evaluator.position['F'] = 1000
    t.call('G1 X10').must_equal 'G1 X10 F1000'
  end

  it "fills current feedrate with line number" do
    t = GcodeVm::FillPositionTransformer.new(axis: 'F', evaluator: evaluator)
    evaluator.position['F'] = 1000
    t.call('N0 G1 X10').must_equal 'N0 G1 X10 F1000'
  end

  it "doesn't fill current position of axis in relative mode" do
    t = GcodeVm::FillPositionTransformer.new(axis: 'X', evaluator: evaluator)
    evaluator.position['X'] = 1000
    evaluator.is_absolute = false
    t.call('G1 Y10').must_equal 'G1 Y10'
  end

  it "fills current position of axis in relative mode if the axis is always absolute" do
    t = GcodeVm::FillPositionTransformer.new(axis: 'F', evaluator: evaluator)
    evaluator.position['F'] = 1000
    evaluator.is_absolute = false
    t.call('G1 Y10').must_equal 'G1 Y10 F1000'
  end

  it "fills current feedrate with line comment" do
    t = GcodeVm::FillPositionTransformer.new(axis: 'F', evaluator: evaluator)
    evaluator.position['F'] = 1000
    t.call('G1 X10 ; comment text').must_equal 'G1 X10 F1000; comment text'
    t.call('G1 X10; comment text').must_equal 'G1 X10 F1000; comment text'
  end

  it "passes through nil and non-strings" do
    t = GcodeVm::FillPositionTransformer.new(axis: 'F', evaluator: evaluator)
    t.call(42).must_equal 42
    t.call(nil).must_be_nil
  end

end
