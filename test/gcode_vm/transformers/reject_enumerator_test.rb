require 'test_helper'

describe GcodeVm::RejectEnumerator do

  it "rejects based on regex condition" do
    cond = GcodeVm::MatchCondition.new(pattern: /w/)
    enum = GcodeVm::RejectEnumerator.new(condition: cond)
    enum.source_enum = %w[one two three].each
    _(enum.to_a).must_equal ['one', 'three']
  end

  it "rejects based on legacy pattern regex" do
    expect {
      enum = GcodeVm::RejectEnumerator.new(pattern: /w/)
      enum.source_enum = %w[one two three].each
      _(enum.to_a).must_equal ['one', 'three']
    }.must_output(nil, "DEPRECATION: using \"pattern\" for \"reject\" in a transform file is deprecated; use \"if\" instead\n")
  end

  it "disallows using both condition and pattern" do
    condition = GcodeVm::MatchCondition.new(pattern: /bar/)
    expect {
      GcodeVm::RejectEnumerator.new(pattern: /foo/,
                                    condition: condition)
    }.must_raise(ArgumentError)
  end

  it "disallows using neither condition nor pattern" do
    expect {
      GcodeVm::RejectEnumerator.new
    }.must_raise(ArgumentError)
  end

end
