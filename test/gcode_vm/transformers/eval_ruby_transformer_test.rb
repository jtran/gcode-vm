require 'test_helper'

describe GcodeVm::EvalRubyTransformer do

  it "indicates that it needs a container injected" do
    _(GcodeVm::EvalRubyTransformer.needs).must_equal :container
  end

  it "evals code and calls it" do
    t = GcodeVm::EvalRubyTransformer.new(code: "proc {|x| x + 1 }")
    _(t.call(41)).must_equal 42
  end

  it "re-evaluates code after setting it and calls it" do
    t = GcodeVm::EvalRubyTransformer.new(code: "proc {|x| x + 1 }")
    _(t.call(41)).must_equal 42
    t.code = "proc {|x| x + 13 }"
    _(t.call(1)).must_equal 14
  end

  it "evals code with class definition, instantiates it, and calls it" do
    t = GcodeVm::EvalRubyTransformer.new(code: <<-EOS)
      Class.new do
        def call(x)
          x + 1
        end
      end
    EOS
    _(t.call(41)).must_equal 42
  end

end
