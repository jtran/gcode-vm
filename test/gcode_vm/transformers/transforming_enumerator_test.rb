require 'test_helper'

describe GcodeVm::TransformingEnumerator do

  it "transforms values from source enumerator" do
    source_enum = %w[One Two Three].each
    t = GcodeVm::TransformingEnumerator.new(source_enum)
      .pipe(&:upcase)
    _(t.to_a).must_equal ['ONE', 'TWO', 'THREE']
  end

  it "transforms values from source enumerator using peek" do
    source_enum = %w[One Two Three].each
    t = GcodeVm::TransformingEnumerator.new(source_enum)
      .pipe(&:upcase)
    _(t.peek).must_equal 'ONE'
    t.next
    _(t.peek).must_equal 'TWO'
    t.next
    _(t.peek).must_equal 'THREE'
  end

  it "pipes array of transforms" do
    source_enum = [2, 3, 4].each
    t = GcodeVm::TransformingEnumerator.new(source_enum)
      .pipe([proc {|x| x * x}, proc {|x| x + 1 }])
    _(t.to_a).must_equal [5, 10, 17]
  end

  it "pipes transforming enumerator" do
    source_enum = [4, 5, 6].each
    transforming_enum = GcodeVm::InjectEnumerator.new(values: [1, 2, 3])
    t = GcodeVm::TransformingEnumerator.new(source_enum)
      .pipe(transforming_enum)
    _(t.to_a).must_equal [1, 2, 3, 4, 5, 6]
  end

  it "disallows piping both argument and block" do
    source_enum = [4, 5, 6].each
    t = GcodeVm::TransformingEnumerator.new(source_enum)
    expect {
      t.pipe(proc {|x| x }) {|x| x }
    }.must_raise(ArgumentError)
  end

end
