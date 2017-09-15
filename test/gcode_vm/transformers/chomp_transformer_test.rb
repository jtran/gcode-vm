require 'test_helper'

describe GcodeVm::ChompTransformer do

  let(:transformer) { GcodeVm::ChompTransformer.new }

  it "removes trailing newline character" do
    transformer.call("hello\n").must_equal('hello')
  end

  it "passes through objects that aren't strings" do
    transformer.call(42).must_equal 42
    transformer.call(nil).must_be_nil
  end

end
