require 'test_helper'

describe GcodeVm::OrCondition do

  it "returns true when any of its child conditions are true" do
    c1 = proc { true }
    c2 = proc { false }
    cond = GcodeVm::OrCondition.new(conditions: [c1, c2])
    _(cond.call('foo')).must_equal true
  end

  it "returns false when none of its child conditions are true" do
    c1 = proc { false }
    c2 = proc { false }
    cond = GcodeVm::OrCondition.new(conditions: [c1, c2])
    _(cond.call('foo')).must_equal false
  end

end
