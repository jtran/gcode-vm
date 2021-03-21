require 'test_helper'

describe GcodeVm::TransitionCondition do

  it "returns true when transitioning to true" do
    match_cond = GcodeVm::MatchCondition.new(pattern: /blue/)
    c = GcodeVm::TransitionCondition.new(condition: match_cond, transition: :to_truthy)
    _(c.call('first')).must_equal false
    _(c.call('second')).must_equal false
    _(c.call('blue')).must_equal true
    _(c.call('blue also')).must_equal false
    _(c.call('blue last')).must_equal false
    _(c.call('third')).must_equal false
    _(c.call('fourth')).must_equal false
    _(c.call('blue again')).must_equal true
    _(c.call('blue too')).must_equal false
  end

  it "returns true when transitioning to false" do
    match_cond = GcodeVm::MatchCondition.new(pattern: /blue/)
    c = GcodeVm::TransitionCondition.new(condition: match_cond, transition: :to_falsey)
    _(c.call('first')).must_equal true
    _(c.call('second')).must_equal false
    _(c.call('blue')).must_equal false
    _(c.call('blue also')).must_equal false
    _(c.call('blue last')).must_equal false
    _(c.call('third')).must_equal true
    _(c.call('fourth')).must_equal false
    _(c.call('blue again')).must_equal false
    _(c.call('blue too')).must_equal false
  end

  it "returns true when transitioning to anything" do
    match_cond = GcodeVm::MatchCondition.new(pattern: /blue/)
    c = GcodeVm::TransitionCondition.new(condition: match_cond, transition: :any)
    _(c.call('first')).must_equal false
    _(c.call('second')).must_equal false
    _(c.call('blue')).must_equal true
    _(c.call('blue also')).must_equal false
    _(c.call('blue last')).must_equal false
    _(c.call('third')).must_equal true
    _(c.call('fourth')).must_equal false
    _(c.call('blue again')).must_equal true
    _(c.call('blue too')).must_equal false
  end

  it "disallows unknown transition type" do
    match_cond = GcodeVm::MatchCondition.new(pattern: /blue/)
    expect {
      GcodeVm::TransitionCondition.new(condition: match_cond, transition: :pattern)
    }.must_raise(ArgumentError)
  end

end
