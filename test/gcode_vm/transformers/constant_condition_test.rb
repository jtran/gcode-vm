require 'test_helper'

describe GcodeVm::ConstantCondition do

  it "returns its value regardless of input" do
    c = GcodeVm::ConstantCondition.new(value: 42)
    c.call(2).must_equal 42
    c.call(nil).must_equal 42
    c.call('foo').must_equal 42
  end

end
