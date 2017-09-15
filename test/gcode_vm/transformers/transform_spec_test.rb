require 'test_helper'

describe GcodeVm::TransformSpec do

  let(:container) { GcodeVm::Container.new }

  let(:evaluator) { GcodeVm::Evaluator.new }

  before do
    container.register(:evaluator) { evaluator }
  end

  it "loads transforms from file" do
    filename = Pathname.new('test/data/simple_transform.yml').expand_path(PROJECT_ROOT).to_s
    result = GcodeVm::TransformSpec.load_file(filename, container: container)

    result.must_be_instance_of Array
    result[0].must_be_instance_of GcodeVm::AxisScaleTransformer
    result[0].multiplier.must_equal 1.5
  end

  it "parses transform YAML from file" do
    filename = Pathname.new('test/data/simple_transform.yml').expand_path(PROJECT_ROOT).to_s
    result = GcodeVm::TransformSpec.parse(filename)

    result.must_be_instance_of ActiveSupport::HashWithIndifferentAccess
    result[:transform].must_be_instance_of Array
  end

  it "loads transform from string" do
    ts = GcodeVm::TransformSpec.load(['identity'], container: container)
    ts[0].must_be_instance_of GcodeVm::IdentityTransformer
    ts.size.must_equal 1
  end

  it "loads transform from hash" do
    ts = GcodeVm::TransformSpec.load([
      name: 'split',
      pattern: 'foo',
    ], container: container)
    ts[0].must_be_instance_of GcodeVm::SplitEnumerator
    ts[0].pattern.must_equal 'foo'
    ts.size.must_equal 1
  end

  it "loads transform from hash when there's a comment field" do
    ts = GcodeVm::TransformSpec.load([
      name: 'split',
      pattern: 'foo',
      comment: 'bar',
    ], container: container)
    ts[0].must_be_instance_of GcodeVm::SplitEnumerator
    ts[0].pattern.must_equal 'foo'
    ts.size.must_equal 1
  end

  it "disallows load of unsafe transform and calls callback" do
    called = false

    fn = Proc.new {|name| called = true }

    spec = {
      name: 'eval_ruby',
      code: 'evil code',
    }

    GcodeVm::TransformSpec.load(spec, unsafe_error: fn, container: container)

    called.must_equal true
  end

  it "loads transform with if condition" do
    ts = GcodeVm::TransformSpec.load({
      name: 'chomp',
      if: '/[a-z]+/',
    }, container: container)
    ts[0].must_be_instance_of GcodeVm::ConditionalTransformer
    ts[0].condition.must_be_instance_of GcodeVm::MatchCondition
    ts[0].condition.pattern.must_equal(/[a-z]+/)
    ts[0].transformer.must_be_instance_of GcodeVm::ChompTransformer
  end

  it "loads transform with unless condition" do
    ts = GcodeVm::TransformSpec.load({
      name: 'chomp',
      unless: '/[a-z]+/',
    }, container: container)
    ts[0].must_be_instance_of GcodeVm::ConditionalTransformer
    ts[0].condition.must_be_instance_of GcodeVm::NotCondition
    ts[0].condition.condition.must_be_instance_of GcodeVm::MatchCondition
    ts[0].condition.condition.pattern.must_equal(/[a-z]+/)
    ts[0].transformer.must_be_instance_of GcodeVm::ChompTransformer
  end

  it "loads transform with both if and unless conditions and ANDs them together" do
    ts = GcodeVm::TransformSpec.load({
      name: 'chomp',
      if: '/[a-z]+/',
      unless: '/[aeiou]+/',
    }, container: container)
    ts[0].must_be_instance_of GcodeVm::ConditionalTransformer
    ts[0].transformer.must_be_instance_of GcodeVm::ChompTransformer
    and_cond = ts[0].condition
    and_cond.must_be_instance_of GcodeVm::AndCondition
    if_cond = and_cond.conditions[0]
    if_cond.pattern.must_equal(/[a-z]+/)
    not_cond = and_cond.conditions[1]
    not_cond.must_be_instance_of GcodeVm::NotCondition
    unless_cond = not_cond.condition
    unless_cond.must_be_instance_of GcodeVm::MatchCondition
    unless_cond.pattern.must_equal(/[aeiou]+/)
  end

  it "loads transform with an if condition that's a range" do
    ts = GcodeVm::TransformSpec.load({
      name: 'chomp',
      if: '/begin/ ... /end/',
    }, container: container)
    ts[0].must_be_instance_of GcodeVm::ConditionalTransformer
    ts[0].transformer.must_be_instance_of GcodeVm::ChompTransformer
    range_cond = ts[0].condition
    range_cond.must_be_instance_of GcodeVm::RangeCondition
    range_cond.start_condition.pattern.must_equal(/begin/)
    range_cond.end_condition.pattern.must_equal(/end/)
  end

  it "loads extrusion multiplier transform with an if condition" do
    ts = GcodeVm::TransformSpec.load({
      name: 'extrusion_multiplier',
      axis: 'E',
      if: '/foo/',
    }, container: container)
    ts[0].must_be_instance_of GcodeVm::ExtrusionMultiplierEnumerator
    cond = ts[0].condition
    cond.must_be_instance_of GcodeVm::MatchCondition
    cond.pattern.must_equal(/foo/)
  end

  it "loads reject transform with an if condition" do
    ts = GcodeVm::TransformSpec.load({
      name: 'reject',
      if: '/foo/',
    }, container: container)
    ts[0].must_be_instance_of GcodeVm::RejectEnumerator
    cond = ts[0].condition
    cond.must_be_instance_of GcodeVm::MatchCondition
    cond.pattern.must_equal(/foo/)
  end

  it "loads transform with UI metadata" do
    ts = GcodeVm::TransformSpec.load({
      name: 'chomp',
      ui_metadata: {
        foo: 'bar',
      },
    }, container: container)
    ts[0].must_be_instance_of GcodeVm::ChompTransformer
  end

  describe "when loading a transform with a dependency" do
    it "instantiates the transform with the dependency and stores it in the container" do
      container = GcodeVm::Container.new
      container.register(:evaluator, factory: -> {
        GcodeVm::Evaluator.new(axes: GcodeVm::Machine::AEROTECH_AXES)
      })
      ts = GcodeVm::TransformSpec.load({
        name: 'extrusion_multiplier',
        axis: 'E',
      }, container: container)

      # At this point, the Evaluator should have been instantiated and cached.
      container.cached?(:evaluator).must_equal true

      ts[0].evaluator.must_be_instance_of GcodeVm::Evaluator
      ts[0].evaluator.axes.must_be_same_as GcodeVm::Machine::AEROTECH_AXES
      ts[0].evaluator.must_be_same_as container.lookup(:evaluator)
    end

    it "loads Ruby class from file and injects container" do
      filename = Pathname.new('test/data/eval_class.yml').expand_path(PROJECT_ROOT).to_s
      result = GcodeVm::TransformSpec.load_file(filename,
                                                container: container,
                                                allow_unsafe: true)

      result.must_be_instance_of Array
      result[0].must_be_instance_of GcodeVm::EvalRubyTransformer
      result[0].container.must_be_same_as container
    end

    it "raises when a dependency is requested that hasn't been registered" do
      # Empty container.
      container = GcodeVm::Container.new
      # Don't register anything.
      proc {
        GcodeVm::TransformSpec.load({
          name: 'extrusion_multiplier',
          axis: 'E',
        }, container: container)
      }.must_raise(RuntimeError)
    end
  end

end
