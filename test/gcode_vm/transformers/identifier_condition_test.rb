require 'test_helper'

describe GcodeVm::IdentifierCondition do

  describe "when using changing_to" do
    it "returns a transition condition" do
      id_cond = GcodeVm::IdentifierCondition.new(id: 'changing_to')
      match_cond = GcodeVm::MatchCondition.new(pattern: /foo/)
      c = id_cond.call(match_cond)
      c.must_be_instance_of GcodeVm::TransitionCondition
      c.transition.must_equal :to_truthy
      c.previous_value.must_equal false
    end

    it "returns the same transition condition instance each time it's called" do
      id_cond = GcodeVm::IdentifierCondition.new(id: 'changing_to')
      match_cond = GcodeVm::MatchCondition.new(pattern: /foo/)
      c1 = id_cond.call(match_cond)
      c2 = id_cond.call(match_cond)
      c1.must_be_same_as c2
    end
  end

  describe "when using changing_from" do
    it "returns a transition condition" do
      id_cond = GcodeVm::IdentifierCondition.new(id: 'changing_from')
      match_cond = GcodeVm::MatchCondition.new(pattern: /foo/)
      c = id_cond.call(match_cond)
      c.must_be_instance_of GcodeVm::TransitionCondition
      c.transition.must_equal :to_falsey
      c.previous_value.must_equal true
    end

    it "returns the same transition condition instance each time it's called" do
      id_cond = GcodeVm::IdentifierCondition.new(id: 'changing_from')
      match_cond = GcodeVm::MatchCondition.new(pattern: /foo/)
      c1 = id_cond.call(match_cond)
      c2 = id_cond.call(match_cond)
      c1.must_be_same_as c2
    end
  end

  describe "when using not" do
    it "returns a not condition" do
      id_cond = GcodeVm::IdentifierCondition.new(id: 'not')
      match_cond = GcodeVm::MatchCondition.new(pattern: /foo/)
      c = id_cond.call(match_cond)
      c.must_be_instance_of GcodeVm::NotCondition
      c.condition.must_be_same_as match_cond
      id_cond.call(match_cond).must_be_same_as c
    end
  end

  it "raises when called on unknown identifier" do
    c = GcodeVm::IdentifierCondition.new(id: 'foo')
    expect {
      c.call('bar')
    }.must_raise(RuntimeError)
  end

end
