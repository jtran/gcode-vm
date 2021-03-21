require 'test_helper'

describe GcodeVm::ReplaceTransformer do

  it "replaces regexp with string" do
    t = GcodeVm::ReplaceTransformer.new(pattern: /,\s*/, with: '|')
    _(t.call('a, b,   c')).must_equal 'a|b|c'
  end

  it "passes through objects that aren't strings" do
    t = GcodeVm::ReplaceTransformer.new(pattern: /,\s*/, with: '|')
    _(t.call(42)).must_equal 42
    _(t.call(nil)).must_be_nil
  end

  it "disallows multiline replacement" do
    expect {
      GcodeVm::ReplaceTransformer.new(pattern: /foo/, with: "first\nsecond")
    }.must_raise(ArgumentError)
  end

  it "disallows multiline replacement when using Windows line endings" do
    expect {
      GcodeVm::ReplaceTransformer.new(pattern: /foo/, with: "first\r\nsecond")
    }.must_raise(ArgumentError)
  end

  it "allows multiline replacement when opting in" do
    t = GcodeVm::ReplaceTransformer.new(pattern: /foo/,
                                        with: "first\nsecond",
                                        multiline_output: true)
    _(t.call('foobar')).must_equal "first\nsecondbar"
  end

end
