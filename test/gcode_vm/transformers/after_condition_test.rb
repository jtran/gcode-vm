require 'test_helper'

describe GcodeVm::AfterCondition do

  it "returns true only after the pattern is matched" do
    c_start = GcodeVm::MatchCondition.new(pattern: /begin/)
    cond = GcodeVm::AfterCondition.new(start_condition: c_start)
    _(cond.call('foo')).must_equal false
    _(cond.call('begin')).must_equal true
    _(cond.call('bar')).must_equal true
    _(cond.call('baz')).must_equal true
    _(cond.call('end')).must_equal true
    _(cond.call('between')).must_equal true
    _(cond.call('begin')).must_equal true
    _(cond.call('end')).must_equal true
    _(cond.call('after')).must_equal true
  end

end
