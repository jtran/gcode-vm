require 'test_helper'

describe GcodeVm::BeforeCondition do

  it "returns true before the pattern is matched" do
    c_end = GcodeVm::MatchCondition.new(pattern: /end/)
    cond = GcodeVm::BeforeCondition.new(end_condition: c_end)
    _(cond.call('foo')).must_equal true
    _(cond.call('begin')).must_equal true
    _(cond.call('bar')).must_equal true
    _(cond.call('baz')).must_equal true
    _(cond.call('end')).must_equal true
    _(cond.call('between')).must_equal false
    _(cond.call('begin')).must_equal false
    _(cond.call('end')).must_equal false
    _(cond.call('after')).must_equal false
  end

end
