require 'test_helper'

describe GcodeVm::RangeCondition do

  it "returns true when within the range and matches multiple ranges" do
    c1 = GcodeVm::MatchCondition.new(pattern: /begin/)
    c2 = GcodeVm::MatchCondition.new(pattern: /end/)
    cond = GcodeVm::RangeCondition.new(start_condition: c1, end_condition: c2)
    cond.call('foo').must_equal false
    cond.call('begin').must_equal true
    cond.call('bar').must_equal true
    cond.call('baz').must_equal true
    cond.call('end').must_equal true
    cond.call('between').must_equal false
    cond.call('begin').must_equal true
    cond.call('end').must_equal true
    cond.call('after').must_equal false
  end

end
