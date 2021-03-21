require 'test_helper'

describe GcodeVm::ConstantCondition do

  it "returns its value regardless of input" do
    c = GcodeVm::ConstantCondition.new(value: 42)
    _(c.call(2)).must_equal 42
    _(c.call(nil)).must_equal 42
    _(c.call('foo')).must_equal 42
  end

end
