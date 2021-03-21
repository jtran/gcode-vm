require 'test_helper'

describe GcodeVm::IdentityTransformer do

  it "returns its arg" do
    t = GcodeVm::IdentityTransformer.new
    _(t.call(42)).must_equal 42
    _(t.call(nil)).must_be_nil
  end

end
