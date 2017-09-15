require 'test_helper'

describe GcodeVm::AndCondition do

  it "returns true when all its child conditions are true" do
    c1 = proc { true }
    c2 = proc { true }
    cond = GcodeVm::AndCondition.new(conditions: [c1, c2])
    cond.call('foo').must_equal true
  end

  it "returns false when any of its child conditions are false" do
    c1 = proc { true }
    c2 = proc { false }
    cond = GcodeVm::AndCondition.new(conditions: [c1, c2])
    cond.call('foo').must_equal false
  end

end
