require 'test_helper'

describe GcodeVm::Condition do

  it "parses regexp" do
    c = GcodeVm::Condition.parse('/\s*fo+/')
    c.must_be_instance_of GcodeVm::MatchCondition
    c.pattern.must_equal(/\s*fo+/)
  end

  it "parses regexp with escape sequences" do
    c = GcodeVm::Condition.parse("/http:\\/\\//")
    c.must_be_instance_of GcodeVm::MatchCondition
    # Note: #== on the Regexp fails since the source of the Regexp literal is
    # slightly different, so comparing the result of #inspect instead.
    c.pattern.inspect.must_equal(%r{http://}.inspect)
  end

  it "parses regexp with multiple option modifiers" do
    c = GcodeVm::Condition.parse('/yes/imxn')
    c.must_be_instance_of GcodeVm::MatchCondition
    c.pattern.must_equal(/yes/imxn)
  end

  it "parses zero-length regexp" do
    c = GcodeVm::Condition.parse('//')
    c.must_be_instance_of GcodeVm::MatchCondition
    c.pattern.must_equal(//)
    c = GcodeVm::Condition.parse('//im')
    c.must_be_instance_of GcodeVm::MatchCondition
    c.pattern.must_equal(//im)
    c = GcodeVm::Condition.parse('//i')
    c.must_be_instance_of GcodeVm::MatchCondition
    c.pattern.must_equal(//i)
  end

  it "parses regexp range" do
    c = GcodeVm::Condition.parse('/\s*fo+/.../bar/')
    c.must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    c1.must_be_instance_of GcodeVm::MatchCondition
    c1.pattern.must_equal(/\s*fo+/)
    c2.must_be_instance_of GcodeVm::MatchCondition
    c2.pattern.must_equal(/bar/)
  end

  it "parses regexp range with spaces" do
    c = GcodeVm::Condition.parse(' /\s*fo+/  ... /bar/ ')
    c.must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    c1.must_be_instance_of GcodeVm::MatchCondition
    c1.pattern.must_equal(/\s*fo+/)
    c2.must_be_instance_of GcodeVm::MatchCondition
    c2.pattern.must_equal(/bar/)
  end

  it "parses regexp range with three dots in regexp" do
    c = GcodeVm::Condition.parse('/.../.../.../')
    c.must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    c1.must_be_instance_of GcodeVm::MatchCondition
    c1.pattern.must_equal(/.../)
    c2.must_be_instance_of GcodeVm::MatchCondition
    c2.pattern.must_equal(/.../)
  end

  it "parses regexp range with open ending" do
    c = GcodeVm::Condition.parse('/begin/ ...')
    c.must_be_instance_of GcodeVm::AfterCondition
    c1 = c.start_condition
    c1.must_be_instance_of GcodeVm::MatchCondition
    c1.pattern.must_equal(/begin/)
  end

  it "parses regexp range with open beginning" do
    c = GcodeVm::Condition.parse('... /end/')
    c.must_be_instance_of GcodeVm::BeforeCondition
    c2 = c.end_condition
    c2.must_be_instance_of GcodeVm::MatchCondition
    c2.pattern.must_equal(/end/)
  end

  it "parses range of regexp ranges" do
    c = GcodeVm::Condition.parse('(/foo/.../bar/) ... (/baz/.../boo/)')
    c.must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    c1.must_be_instance_of GcodeVm::RangeCondition
    c1_1 = c1.start_condition
    c1_2 = c1.end_condition
    c1_1.must_be_instance_of GcodeVm::MatchCondition
    c1_1.pattern.must_equal(/foo/)
    c1_2.must_be_instance_of GcodeVm::MatchCondition
    c1_2.pattern.must_equal(/bar/)
    c2.must_be_instance_of GcodeVm::RangeCondition
    c2_1 = c2.start_condition
    c2_2 = c2.end_condition
    c2_1.must_be_instance_of GcodeVm::MatchCondition
    c2_1.pattern.must_equal(/baz/)
    c2_2.must_be_instance_of GcodeVm::MatchCondition
    c2_2.pattern.must_equal(/boo/)
  end

  it "parses range of regexp range and regexp when using parentheses" do
    c = GcodeVm::Condition.parse('(/foo/.../bar/) ... /baz/')
    c.must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    c1.must_be_instance_of GcodeVm::RangeCondition
    c1_1 = c1.start_condition
    c1_2 = c1.end_condition
    c1_1.must_be_instance_of GcodeVm::MatchCondition
    c1_1.pattern.must_equal(/foo/)
    c1_2.must_be_instance_of GcodeVm::MatchCondition
    c1_2.pattern.must_equal(/bar/)
    c2.must_be_instance_of GcodeVm::MatchCondition
    c2.pattern.must_equal(/baz/)
  end

  it "parses range of regexp and regexp range when using parentheses" do
    c = GcodeVm::Condition.parse('/foo/...(/bar/ ... /baz/)')
    c.must_be_instance_of GcodeVm::RangeCondition
    c1 = c.start_condition
    c2 = c.end_condition
    c1.must_be_instance_of GcodeVm::MatchCondition
    c1.pattern.must_equal(/foo/)
    c2.must_be_instance_of GcodeVm::RangeCondition
    c2_1 = c2.start_condition
    c2_2 = c2.end_condition
    c2_1.must_be_instance_of GcodeVm::MatchCondition
    c2_1.pattern.must_equal(/bar/)
    c2_2.must_be_instance_of GcodeVm::MatchCondition
    c2_2.pattern.must_equal(/baz/)
  end

  it "rejects parsing triple regexp range without parentheses" do
    # If you want to parse this, you should explicitly use parentheses.
    proc {
      GcodeVm::Condition.parse('/one/ ... /two/ ... /three/')
    }.must_raise(Parslet::ParseFailed)
  end

  it "parses true" do
    c = GcodeVm::Condition.parse('true')
    c.must_be_instance_of GcodeVm::ConstantCondition
    c.value.must_equal true
  end

  it "parses false" do
    c = GcodeVm::Condition.parse('false')
    c.must_be_instance_of GcodeVm::ConstantCondition
    c.value.must_equal false
  end

  it "parses identifier" do
    c = GcodeVm::Condition.parse('changing')
    c.must_be_instance_of GcodeVm::IdentifierCondition
    c.id.must_equal 'changing'
  end

  it "parses negation" do
    c = GcodeVm::Condition.parse('not false')
    c.must_be_instance_of GcodeVm::ApplicationCondition
    c.fun.must_be_instance_of GcodeVm::IdentifierCondition
    c.args[0].must_be_kind_of GcodeVm::ConstantCondition
    c.args[0].value.must_equal false
  end

  it "parses negation of a range" do
    c = GcodeVm::Condition.parse('not /begin/ ... /end/')
    c.must_be_instance_of GcodeVm::ApplicationCondition
    c.fun.must_be_instance_of GcodeVm::IdentifierCondition
    c.args[0].must_be_kind_of GcodeVm::RangeCondition
  end

  it "parses changing to pattern" do
    c = GcodeVm::Condition.parse('changing_to /foo/')
    c.must_be_instance_of GcodeVm::ApplicationCondition
    fun = c.fun
    fun.must_be_instance_of GcodeVm::IdentifierCondition
    fun.id.must_equal 'changing_to'
    arg1 = c.args.first
    arg1.must_be_instance_of GcodeVm::MatchCondition
    arg1.pattern.must_equal(/foo/)
    c.args.size.must_equal 1
  end

  it "parses range operator more tightly than application" do
    c = GcodeVm::Condition.parse('changing_to /begin/ ... /end/')
    c.must_be_instance_of GcodeVm::ApplicationCondition
    c.fun.must_be_instance_of GcodeVm::IdentifierCondition
    c.args[0].must_be_instance_of GcodeVm::RangeCondition
    c.args.size.must_equal 1
    arg1 = c.args[0]
    arg1.start_condition.pattern.must_equal(/begin/)
    arg1.end_condition.pattern.must_equal(/end/)
  end

  it "parses range operator more tightly than application with unnecessary parentheses" do
    c = GcodeVm::Condition.parse('changing_to(/begin/ ... /end/)')
    c.must_be_instance_of GcodeVm::ApplicationCondition
    c.fun.must_be_instance_of GcodeVm::IdentifierCondition
    c.args[0].must_be_instance_of GcodeVm::RangeCondition
    c.args.size.must_equal 1
    arg1 = c.args[0]
    arg1.start_condition.pattern.must_equal(/begin/)
    arg1.end_condition.pattern.must_equal(/end/)
  end

  it "parses parentheses to change range operator and application precedence" do
    c = GcodeVm::Condition.parse('(changing_to /begin/) ... /end/')
    c.must_be_instance_of GcodeVm::RangeCondition
    c.start_condition.must_be_instance_of GcodeVm::ApplicationCondition
    c.end_condition.pattern.must_equal(/end/)
    c.start_condition.fun.must_be_instance_of GcodeVm::IdentifierCondition
    c.start_condition.args.size.must_equal 1
    arg1 = c.start_condition.args[0]
    arg1.must_be_instance_of GcodeVm::MatchCondition
    arg1.pattern.must_equal(/begin/)
  end

  it "parses two identifiers combined with and" do
    c = GcodeVm::Condition.parse('true and false')
    c.must_be_instance_of GcodeVm::AndCondition
    c.conditions[0].must_be_kind_of GcodeVm::ConstantCondition
    c.conditions[0].value.must_equal true
    c.conditions[1].must_be_kind_of GcodeVm::ConstantCondition
    c.conditions[1].value.must_equal false
  end

  it "parses two identifiers combined with or" do
    c = GcodeVm::Condition.parse('true or false')
    c.must_be_instance_of GcodeVm::OrCondition
    c.conditions[0].must_be_kind_of GcodeVm::ConstantCondition
    c.conditions[0].value.must_equal true
    c.conditions[1].must_be_kind_of GcodeVm::ConstantCondition
    c.conditions[1].value.must_equal false
  end

  it "parses two regexps combined with and" do
    c = GcodeVm::Condition.parse('/foo/ and /bar/')
    c.must_be_instance_of GcodeVm::AndCondition
    c.conditions[0].must_be_kind_of GcodeVm::MatchCondition
    c.conditions[0].pattern.must_equal(/foo/)
    c.conditions[1].must_be_kind_of GcodeVm::MatchCondition
    c.conditions[1].pattern.must_equal(/bar/)
  end

  it "parses two ranges combined with and" do
    c = GcodeVm::Condition.parse('/foo/.../bar/ and /begin/.../end/')
    c.must_be_instance_of GcodeVm::AndCondition
    c.conditions[0].must_be_kind_of GcodeVm::RangeCondition
    c.conditions[0].start_condition.pattern.must_equal(/foo/)
    c.conditions[0].end_condition.pattern.must_equal(/bar/)
    c.conditions[1].must_be_kind_of GcodeVm::RangeCondition
    c.conditions[1].start_condition.pattern.must_equal(/begin/)
    c.conditions[1].end_condition.pattern.must_equal(/end/)
  end

  it "parses not combined with a binary operator" do
    c = GcodeVm::Condition.parse('true and not false')
    c.must_be_instance_of GcodeVm::AndCondition
    c.conditions[0].must_be_kind_of GcodeVm::ConstantCondition
    c.conditions[0].value.must_equal true
    c.conditions[1].must_be_kind_of GcodeVm::ApplicationCondition
    c.conditions[1].fun.id.must_equal 'not'
    c.conditions[1].args[0].must_be_kind_of GcodeVm::ConstantCondition
    c.conditions[1].args[0].value.must_equal false
  end

  it "combines not with itself in a way that makes sense" do
    c = GcodeVm::Condition.parse('not (not true)')
    c.call('foo').must_equal true
    c = GcodeVm::Condition.parse('not not true')
    expect {
      c.call('foo')
    }.must_raise(RuntimeError)
  end

  it "combines not with other functions in a way that makes sense" do
    c = GcodeVm::Condition.parse('changing_to /foo/')
    c.call('foo').must_equal true
    c = GcodeVm::Condition.parse('not (changing_to /foo/)')
    c.call('foo').must_equal false
  end

  it "has a helpful error message when there's an error due to missing parentheses" do
    c = GcodeVm::Condition.parse('not changing_to /foo/')
    begin
      c.call('foo')
    rescue => e
      e.message.must_match(/adding parentheses/)
      # It should include something from the source.
      e.message.must_match(/changing_to/)
    else
      fail "I expected an error to be raised but there wasn't"
    end
  end

  it "binds not tighter than binary operators and executes correctly" do
    c = GcodeVm::Condition.parse('true and not false')
    c.call('foo').must_equal true
    c = GcodeVm::Condition.parse('not true or false')
    c.call('foo').must_equal false
    c = GcodeVm::Condition.parse('not (true or false)')
    c.call('foo').must_equal false
    c = GcodeVm::Condition.parse('not true and false')
    c.call('foo').must_equal false
    c = GcodeVm::Condition.parse('not (true and false)')
    c.call('foo').must_equal true
  end

end
