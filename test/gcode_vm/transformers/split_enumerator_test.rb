require 'test_helper'

describe GcodeVm::SplitEnumerator do

  it "splits based on regex" do
    enum = GcodeVm::SplitEnumerator.new(pattern: /w/)
    enum.source_enum = ['one', 'two', 'three'].each
    _(enum.to_a).must_equal ['one', 't', 'o', 'three']
  end

  it "allows nil and empty strings to pass through" do
    enum = GcodeVm::SplitEnumerator.new(pattern: /,/)
    enum.source_enum = ['a,b', nil, ''].each
    _(enum.to_a).must_equal ['a', 'b', nil, '']
  end

  it "splits and transforms" do
    enum = GcodeVm::SplitEnumerator.new(pattern: /,/).pipe &:upcase
    enum.source_enum = ['one,two'].each
    _(enum.to_a).must_equal ['ONE', 'TWO']
  end

end
