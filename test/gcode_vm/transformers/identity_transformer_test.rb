require 'test_helper'

describe GcodeVm::IdentityTransformer do

  it "returns its arg" do
    t = GcodeVm::IdentityTransformer.new
    t.call(42).must_equal 42
    t.call(nil).must_be_nil
  end

end
