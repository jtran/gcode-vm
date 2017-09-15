require 'test_helper'

describe GcodeVm::NotCondition do

  it "returns false when its child condition is true" do
    child = proc { true }
    cond = GcodeVm::NotCondition.new(condition: child)
    cond.call('foo').must_equal false
  end

  it "returns true when its child condition is false" do
    child = proc { false }
    cond = GcodeVm::NotCondition.new(condition: child)
    cond.call('foo').must_equal true
  end

end
