require 'test_helper'

describe GcodeVm::InjectEnumerator do

  it "inserts with no pattern" do
    enum = GcodeVm::InjectEnumerator.new(values: 'foo')
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['foo', 'one', 'two', 'three']
  end

  it "inserts before regex" do
    enum = GcodeVm::InjectEnumerator.new(before: /tw\w+/, values: 'foo')
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'foo', 'two', 'three']
  end

  it "inserts before string" do
    enum = GcodeVm::InjectEnumerator.new(before: 'two', values: 'foo')
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'foo', 'two', 'three']
  end

  it "inserts and transforms" do
    enum = GcodeVm::InjectEnumerator.new(values: 'foo')
      .pipe(&:upcase)
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['FOO', 'ONE', 'TWO', 'THREE']
  end

  it "inserts before regex and transforms" do
    enum = GcodeVm::InjectEnumerator.new(before: /tw\w+/, values: 'foo')
      .pipe(&:upcase)
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['ONE', 'FOO', 'TWO', 'THREE']
  end

  it "inserts multiple values" do
    enum = GcodeVm::InjectEnumerator.new(before: /tw\w+/, values: ['foo', 'bar'])
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'foo', 'bar', 'two', 'three']
  end

  describe "when there are many matches" do
    it "inserts only once" do
      enum = GcodeVm::InjectEnumerator.new(before: /t/, values: 'foo')
      enum.source_enum = ['one', 'two', 'three'].each
      enum.to_a.must_equal ['one', 'foo', 'two', 'three']
    end
  end

end
