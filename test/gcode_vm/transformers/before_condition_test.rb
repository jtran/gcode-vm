require 'test_helper'

describe GcodeVm::BeforeCondition do

  it "returns true before the pattern is matched" do
    c_end = GcodeVm::MatchCondition.new(pattern: /end/)
    cond = GcodeVm::BeforeCondition.new(end_condition: c_end)
    cond.call('foo').must_equal true
    cond.call('begin').must_equal true
    cond.call('bar').must_equal true
    cond.call('baz').must_equal true
    cond.call('end').must_equal true
    cond.call('between').must_equal false
    cond.call('begin').must_equal false
    cond.call('end').must_equal false
    cond.call('after').must_equal false
  end

end
