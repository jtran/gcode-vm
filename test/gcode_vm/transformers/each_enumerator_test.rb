require 'test_helper'

describe GcodeVm::EachEnumerator do

  it "tracks current index" do
    enum = GcodeVm::EachEnumerator.new
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a
    _(enum.index).must_equal 3
  end

  it "calls progress block with values and indices" do
    values = []
    indices = []
    enum = GcodeVm::EachEnumerator.new(on_progress: proc {|val, index|
      values << val
      indices << index
    })
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a
    _(values).must_equal ['one', 'two', 'three']
    _(indices).must_equal [0, 1, 2]
  end

  it "calls block with values and indices when instantiated with a block" do
    values = []
    indices = []
    enum = GcodeVm::EachEnumerator.new {|val, index|
      values << val
      indices << index
    }
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a
    _(values).must_equal ['one', 'two', 'three']
    _(indices).must_equal [0, 1, 2]
  end

  it "calls complete block with exception and index" do
    error = nil
    index = nil
    enum = GcodeVm::EachEnumerator.new(on_complete: proc {|e, i|
      error = e
      index = i
    })
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a
    _(error).must_be_instance_of StopIteration
    _(index).must_equal 3
  end

  it "calls block after pulling value from source and before transforming" do
    # This is to test that things execute in the order that you pipe them.
    values = []
    enum = GcodeVm::EachEnumerator.new(on_progress: proc {|val, index|
      values << val
    })
    enum.source_enum = ['one', 'two', 'three'].each
    enum = enum.pipe(&:upcase)
    _(enum.to_a).must_equal ['ONE', 'TWO', 'THREE']
    _(values).must_equal ['one', 'two', 'three']
  end

  it "disallows instantiating with both on_progress and a block" do
    expect {
      GcodeVm::EachEnumerator.new(on_progress: proc {|val, i| }) {|val,i| }
    }.must_raise ArgumentError
  end

end
