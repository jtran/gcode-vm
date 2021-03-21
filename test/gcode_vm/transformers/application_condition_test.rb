require 'test_helper'

describe GcodeVm::ApplicationCondition do

  it "applies argument to higher-order condition" do
    id_cond = GcodeVm::IdentifierCondition.new(id: 'changing_to')
    match_cond = GcodeVm::MatchCondition.new(pattern: /blue/)
    c = GcodeVm::ApplicationCondition.new(fun: id_cond, args: [match_cond])
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

end
