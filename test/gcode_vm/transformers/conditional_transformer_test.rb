require 'test_helper'

describe GcodeVm::ConditionalTransformer do

  it "calls transformer only when matching regexp" do
    upcase = proc {|s| s.upcase }
    cond = GcodeVm::MatchCondition.new(pattern: /f[a-z]+/)
    t = GcodeVm::ConditionalTransformer.new(condition: cond, transformer: upcase)
    _(t.call('hello')).must_equal('hello')
    _(t.call('foo')).must_equal('FOO')
  end

  it "calls else transformer only when not matching regexp" do
    upcase = proc {|s| s.upcase }
    downcase = proc {|s| s.downcase }
    cond = GcodeVm::MatchCondition.new(pattern: /f[a-z]+/)
    t = GcodeVm::ConditionalTransformer.new(condition: cond, transformer: upcase, else_transformer: downcase)
    _(t.call('Hello')).must_equal('hello')
    _(t.call('foo')).must_equal('FOO')
  end

end
