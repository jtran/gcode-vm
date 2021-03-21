require 'test_helper'

describe GcodeVm::ConcatEnumerator do

  it "concatenates multiple enumerators" do
    enum = GcodeVm::ConcatEnumerator.new(source_enums:
             [['one', 'two', 'three'].each, ['a', 'b', 'c'].each])
    _(enum.to_a).must_equal ['one', 'two', 'three', 'a', 'b', 'c']
  end

  it "concatenates multiple enumerators using peek" do
    enum = GcodeVm::ConcatEnumerator.new
    enum.source_enums = [['one', 'two', 'three'].each, ['a', 'b', 'c'].each]
    _(enum.peek).must_equal 'one'
    _(enum.next).must_equal 'one'
    _(enum.next).must_equal 'two'
    _(enum.next).must_equal 'three'
    _(enum.peek).must_equal 'a'
    _(enum.next).must_equal 'a'
    _(enum.next).must_equal 'b'
    _(enum.next).must_equal 'c'
    expect {
      enum.peek
    }.must_raise StopIteration
    expect {
      enum.next
    }.must_raise StopIteration
  end

  it "sums sizes" do
    enum = GcodeVm::ConcatEnumerator.new(source_enums:
             [['one', 'two', 'three'].each, ['a', 'b', 'c'].each])
    _(enum.size).must_equal 6
  end

  it "returns nil size when unknown" do
    enum = GcodeVm::ConcatEnumerator.new(source_enums:
             [['one', 'two', 'three'].each, $stdin.each_line])
    _(enum.size).must_be_nil
  end

  it "returns infinity when size is infinite" do
    enum = GcodeVm::ConcatEnumerator.new(source_enums:
             [['one', 'two', 'three'].each, (1..Float::INFINITY).each])
    _(enum.size).must_equal Float::INFINITY
  end

end
