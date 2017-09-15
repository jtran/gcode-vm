require 'test_helper'

describe GcodeVm::InsertEnumerator do

  it "inserts before pattern based on regex" do
    enum = GcodeVm::InsertEnumerator.new(text: 'foo', before: "/tw\\w+/")
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'foo', 'two', 'three']
  end

  it "inserts before pattern based on transition condition" do
    enum = GcodeVm::InsertEnumerator.new(text: 'foo', before: "changing_to /t/")
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'foo', 'two', 'three']
  end

  it "inserts after pattern based on regex" do
    enum = GcodeVm::InsertEnumerator.new(text: 'foo', after: "/tw\\w+/")
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'two', 'foo', 'three']
  end

  it "inserts after pattern based on transition condition" do
    enum = GcodeVm::InsertEnumerator.new(text: 'foo', after: "changing_to /t/")
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'two', 'foo', 'three']
  end

  it "inserts based on regex and transforms" do
    enum = GcodeVm::InsertEnumerator.new(text: 'foo', before: "/tw\\w+/")
      .pipe(&:upcase)
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['ONE', 'FOO', 'TWO', 'THREE']
  end

  it "inserts multiple values before pattern" do
    enum = GcodeVm::InsertEnumerator.new(text: "foo\nbar", before: "/tw\\w+/")
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'foo', 'bar', 'two', 'three']
  end

  it "inserts multiple values after pattern" do
    enum = GcodeVm::InsertEnumerator.new(text: "foo\nbar", after: "/tw\\w+/")
    enum.source_enum = ['one', 'two', 'three'].each
    enum.to_a.must_equal ['one', 'two', 'foo', 'bar', 'three']
  end

  describe "when there are many matches" do
    it "inserts only once" do
      enum = GcodeVm::InsertEnumerator.new(text: 'foo', before: '/t/')
      enum.source_enum = ['one', 'two', 'three'].each
      enum.to_a.must_equal ['one', 'foo', 'two', 'three']
    end

    it "inserts many times when global is true" do
      enum = GcodeVm::InsertEnumerator.new(text: 'foo', before: '/t/', global: true)
      enum.source_enum = ['one', 'two', 'three'].each
      enum.to_a.must_equal ['one', 'foo', 'two', 'foo', 'three']
    end
  end

  it "disallows instantiating with both before and after arguments" do
    proc {
      GcodeVm::InsertEnumerator.new(text: 'foo', before: 'true', after: 'false')
    }.must_raise(ArgumentError)
  end

end
