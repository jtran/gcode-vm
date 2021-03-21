require 'test_helper'

describe GcodeVm::Condition do

  it "parses regexp" do
    c = GcodeVm::Condition.parse('/\s*fo+/')
    _(c).must_be_instance_of GcodeVm::MatchCondition
    _(c.pattern).must_equal(/\s*fo+/)
  end

  it "parses regexp with escape sequences" do
    c = GcodeVm::Condition.parse("/http:\\/\\//")
    _(c).must_be_instance_of GcodeVm::MatchCondition
    # Note: #== on the Regexp fails since the source of the Regexp literal is
    # slightly different, so comparing the result of #inspect instead.
    _(c.pattern.inspect).must_equal(%r{http://}.inspect)
  end

  it "parses regexp with multiple option modifiers" do
    c = GcodeVm::Condition.parse('/yes/imxn')
    _(c).must_be_instance_of GcodeVm::MatchCondition
    _(c.pattern).must_equal(/yes/imxn)
  end

  it "parses zero-length regexp" do
    c = GcodeVm::Condition.parse('//')
    _(c).must_be_instance_of GcodeVm::MatchCondition
    _(c.pattern).must_equal(//)
    c = GcodeVm::Condition.parse('//im')
    _(c).must_be_instance_of GcodeVm::MatchCondition
    _(c.pattern).must_equal(//im)
    c = GcodeVm::Condition.parse('//i')
    _(c).must_be_instance_of GcodeVm::MatchCondition
    _(c.pattern).must_equal(//i)
  end

  it "parses regexp range" do
    c = GcodeVm::Condition.parse('/\s*fo+/.../bar/')
    _(c).must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    _(c1).must_be_instance_of GcodeVm::MatchCondition
    _(c1.pattern).must_equal(/\s*fo+/)
    _(c2).must_be_instance_of GcodeVm::MatchCondition
    _(c2.pattern).must_equal(/bar/)
  end

  it "parses regexp range with spaces" do
    c = GcodeVm::Condition.parse(' /\s*fo+/  ... /bar/ ')
    _(c).must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    _(c1).must_be_instance_of GcodeVm::MatchCondition
    _(c1.pattern).must_equal(/\s*fo+/)
    _(c2).must_be_instance_of GcodeVm::MatchCondition
    _(c2.pattern).must_equal(/bar/)
  end

  it "parses regexp range with three dots in regexp" do
    c = GcodeVm::Condition.parse('/.../.../.../')
    _(c).must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    _(c1).must_be_instance_of GcodeVm::MatchCondition
    _(c1.pattern).must_equal(/.../)
    _(c2).must_be_instance_of GcodeVm::MatchCondition
    _(c2.pattern).must_equal(/.../)
  end

  it "parses regexp range with open ending" do
    c = GcodeVm::Condition.parse('/begin/ ...')
    _(c).must_be_instance_of GcodeVm::AfterCondition
    c1 = c.start_condition
    _(c1).must_be_instance_of GcodeVm::MatchCondition
    _(c1.pattern).must_equal(/begin/)
  end

  it "parses regexp range with open beginning" do
    c = GcodeVm::Condition.parse('... /end/')
    _(c).must_be_instance_of GcodeVm::BeforeCondition
    c2 = c.end_condition
    _(c2).must_be_instance_of GcodeVm::MatchCondition
    _(c2.pattern).must_equal(/end/)
  end

  it "parses range of regexp ranges" do
    c = GcodeVm::Condition.parse('(/foo/.../bar/) ... (/baz/.../boo/)')
    _(c).must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    _(c1).must_be_instance_of GcodeVm::RangeCondition
    c1_1 = c1.start_condition
    c1_2 = c1.end_condition
    _(c1_1).must_be_instance_of GcodeVm::MatchCondition
    _(c1_1.pattern).must_equal(/foo/)
    _(c1_2).must_be_instance_of GcodeVm::MatchCondition
    _(c1_2.pattern).must_equal(/bar/)
    _(c2).must_be_instance_of GcodeVm::RangeCondition
    c2_1 = c2.start_condition
    c2_2 = c2.end_condition
    _(c2_1).must_be_instance_of GcodeVm::MatchCondition
    _(c2_1.pattern).must_equal(/baz/)
    _(c2_2).must_be_instance_of GcodeVm::MatchCondition
    _(c2_2.pattern).must_equal(/boo/)
  end

  it "parses range of regexp range and regexp when using parentheses" do
    c = GcodeVm::Condition.parse('(/foo/.../bar/) ... /baz/')
    _(c).must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    _(c1).must_be_instance_of GcodeVm::RangeCondition
    c1_1 = c1.start_condition
    c1_2 = c1.end_condition
    _(c1_1).must_be_instance_of GcodeVm::MatchCondition
    _(c1_1.pattern).must_equal(/foo/)
    _(c1_2).must_be_instance_of GcodeVm::MatchCondition
    _(c1_2.pattern).must_equal(/bar/)
    _(c2).must_be_instance_of GcodeVm::MatchCondition
    _(c2.pattern).must_equal(/baz/)
  end

  it "parses range of regexp and regexp range when using parentheses" do
    c = GcodeVm::Condition.parse('/foo/...(/bar/ ... /baz/)')
    _(c).must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    _(c1).must_be_instance_of GcodeVm::MatchCondition
    _(c1.pattern).must_equal(/foo/)
    _(c2).must_be_instance_of GcodeVm::RangeCondition
    c2_1 = c2.start_condition
    c2_2 = c2.end_condition
    _(c2_1).must_be_instance_of GcodeVm::MatchCondition
    _(c2_1.pattern).must_equal(/bar/)
    _(c2_2).must_be_instance_of GcodeVm::MatchCondition
    _(c2_2.pattern).must_equal(/baz/)
  end

  it "rejects parsing triple regexp range without parentheses" do
    # If you want to parse this, you should explicitly use parentheses.
    expect {
      GcodeVm::Condition.parse('/one/ ... /two/ ... /three/')
    }.must_raise(Parslet::ParseFailed)
  end

  it "parses true" do
    c = GcodeVm::Condition.parse('true')
    _(c).must_be_instance_of GcodeVm::ConstantCondition
    _(c.value).must_equal true
  end

  it "parses false" do
    c = GcodeVm::Condition.parse('false')
    _(c).must_be_instance_of GcodeVm::ConstantCondition
    _(c.value).must_equal false
  end

  it "parses identifier" do
    c = GcodeVm::Condition.parse('changing')
    _(c).must_be_instance_of GcodeVm::IdentifierCondition
    _(c.id).must_equal 'changing'
  end

  it "parses negation" do
    c = GcodeVm::Condition.parse('not false')
    _(c).must_be_instance_of GcodeVm::ApplicationCondition
    _(c.fun).must_be_instance_of GcodeVm::IdentifierCondition
    _(c.args[0]).must_be_kind_of GcodeVm::ConstantCondition
    _(c.args[0].value).must_equal false
  end

  it "parses negation of a range" do
    c = GcodeVm::Condition.parse('not /begin/ ... /end/')
    _(c).must_be_instance_of GcodeVm::ApplicationCondition
    _(c.fun).must_be_instance_of GcodeVm::IdentifierCondition
    _(c.args[0]).must_be_kind_of GcodeVm::RangeCondition
  end

  it "parses changing to pattern" do
    c = GcodeVm::Condition.parse('changing_to /foo/')
    _(c).must_be_instance_of GcodeVm::ApplicationCondition
    fun = c.fun
    _(fun).must_be_instance_of GcodeVm::IdentifierCondition
    _(fun.id).must_equal 'changing_to'
    arg1 = c.args.first
    _(arg1).must_be_instance_of GcodeVm::MatchCondition
    _(arg1.pattern).must_equal(/foo/)
    _(c.args.size).must_equal 1
  end

  it "parses range operator more tightly than application" do
    c = GcodeVm::Condition.parse('changing_to /begin/ ... /end/')
    _(c).must_be_instance_of GcodeVm::ApplicationCondition
    _(c.fun).must_be_instance_of GcodeVm::IdentifierCondition
    _(c.args[0]).must_be_instance_of GcodeVm::RangeCondition
    _(c.args.size).must_equal 1
    arg1 = c.args[0]
    _(arg1.start_condition.pattern).must_equal(/begin/)
    _(arg1.end_condition.pattern).must_equal(/end/)
  end

  it "parses range operator more tightly than application with unnecessary parentheses" do
    c = GcodeVm::Condition.parse('changing_to(/begin/ ... /end/)')
    _(c).must_be_instance_of GcodeVm::ApplicationCondition
    _(c.fun).must_be_instance_of GcodeVm::IdentifierCondition
    _(c.args[0]).must_be_instance_of GcodeVm::RangeCondition
    _(c.args.size).must_equal 1
    arg1 = c.args[0]
    _(arg1.start_condition.pattern).must_equal(/begin/)
    _(arg1.end_condition.pattern).must_equal(/end/)
  end

  it "parses parentheses to change range operator and application precedence" do
    c = GcodeVm::Condition.parse('(changing_to /begin/) ... /end/')
    _(c).must_be_instance_of GcodeVm::RangeCondition
    _(c.start_condition).must_be_instance_of GcodeVm::ApplicationCondition
    _(c.end_condition.pattern).must_equal(/end/)
    _(c.start_condition.fun).must_be_instance_of GcodeVm::IdentifierCondition
    _(c.start_condition.args.size).must_equal 1
    arg1 = c.start_condition.args[0]
    _(arg1).must_be_instance_of GcodeVm::MatchCondition
    _(arg1.pattern).must_equal(/begin/)
  end

  it "parses two identifiers combined with and" do
    c = GcodeVm::Condition.parse('true and false')
    _(c).must_be_instance_of GcodeVm::AndCondition
    _(c.conditions[0]).must_be_kind_of GcodeVm::ConstantCondition
    _(c.conditions[0].value).must_equal true
    _(c.conditions[1]).must_be_kind_of GcodeVm::ConstantCondition
    _(c.conditions[1].value).must_equal false
  end

  it "parses two identifiers combined with or" do
    c = GcodeVm::Condition.parse('true or false')
    _(c).must_be_instance_of GcodeVm::OrCondition
    _(c.conditions[0]).must_be_kind_of GcodeVm::ConstantCondition
    _(c.conditions[0].value).must_equal true
    _(c.conditions[1]).must_be_kind_of GcodeVm::ConstantCondition
    _(c.conditions[1].value).must_equal false
  end

  it "parses two regexps combined with and" do
    c = GcodeVm::Condition.parse('/foo/ and /bar/')
    _(c).must_be_instance_of GcodeVm::AndCondition
    _(c.conditions[0]).must_be_kind_of GcodeVm::MatchCondition
    _(c.conditions[0].pattern).must_equal(/foo/)
    _(c.conditions[1]).must_be_kind_of GcodeVm::MatchCondition
    _(c.conditions[1].pattern).must_equal(/bar/)
  end

  it "parses two ranges combined with and" do
    c = GcodeVm::Condition.parse('/foo/.../bar/ and /begin/.../end/')
    _(c).must_be_instance_of GcodeVm::AndCondition
    _(c.conditions[0]).must_be_kind_of GcodeVm::RangeCondition
    _(c.conditions[0].start_condition.pattern).must_equal(/foo/)
    _(c.conditions[0].end_condition.pattern).must_equal(/bar/)
    _(c.conditions[1]).must_be_kind_of GcodeVm::RangeCondition
    _(c.conditions[1].start_condition.pattern).must_equal(/begin/)
    _(c.conditions[1].end_condition.pattern).must_equal(/end/)
  end

  it "parses not combined with a binary operator" do
    c = GcodeVm::Condition.parse('true and not false')
    _(c).must_be_instance_of GcodeVm::AndCondition
    _(c.conditions[0]).must_be_kind_of GcodeVm::ConstantCondition
    _(c.conditions[0].value).must_equal true
    _(c.conditions[1]).must_be_kind_of GcodeVm::ApplicationCondition
    _(c.conditions[1].fun.id).must_equal 'not'
    _(c.conditions[1].args[0]).must_be_kind_of GcodeVm::ConstantCondition
    _(c.conditions[1].args[0].value).must_equal false
  end

  it "combines not with itself in a way that makes sense" do
    c = GcodeVm::Condition.parse('not (not true)')
    _(c.call('foo')).must_equal true
    c = GcodeVm::Condition.parse('not not true')
    expect {
      c.call('foo')
    }.must_raise(RuntimeError)
  end

  it "combines not with other functions in a way that makes sense" do
    c = GcodeVm::Condition.parse('changing_to /foo/')
    _(c.call('foo')).must_equal true
    c = GcodeVm::Condition.parse('not (changing_to /foo/)')
    _(c.call('foo')).must_equal false
  end

  it "has a helpful error message when there's an error due to missing parentheses" do
    c = GcodeVm::Condition.parse('not changing_to /foo/')
    begin
      c.call('foo')
    rescue => e
      _(e.message).must_match(/adding parentheses/)
      # It should include something from the source.
      _(e.message).must_match(/changing_to/)
    else
      fail "I expected an error to be raised but there wasn't"
    end
  end

  it "binds not tighter than binary operators and executes correctly" do
    c = GcodeVm::Condition.parse('true and not false')
    _(c.call('foo')).must_equal true
    c = GcodeVm::Condition.parse('not true or false')
    _(c.call('foo')).must_equal false
    c = GcodeVm::Condition.parse('not (true or false)')
    _(c.call('foo')).must_equal false
    c = GcodeVm::Condition.parse('not true and false')
    _(c.call('foo')).must_equal false
    c = GcodeVm::Condition.parse('not (true and false)')
    _(c.call('foo')).must_equal true
  end

end
