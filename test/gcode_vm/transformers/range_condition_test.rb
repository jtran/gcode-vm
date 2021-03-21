require 'test_helper'

describe GcodeVm::RangeCondition do

  it "returns true when within the range and matches multiple ranges" do
    c1 = GcodeVm::MatchCondition.new(pattern: /begin/)
    c2 = GcodeVm::MatchCondition.new(pattern: /end/)
    cond = GcodeVm::RangeCondition.new(start_condition: c1, end_condition: c2)
    _(cond.call('foo')).must_equal false
    _(cond.call('begin')).must_equal true
    _(cond.call('bar')).must_equal true
    _(cond.call('baz')).must_equal true
    _(cond.call('end')).must_equal true
    _(cond.call('between')).must_equal false
    _(cond.call('begin')).must_equal true
    _(cond.call('end')).must_equal true
    _(cond.call('after')).must_equal false
  end

end
