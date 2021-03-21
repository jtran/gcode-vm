require 'test_helper'

describe GcodeVm::Container do

  let(:container) { GcodeVm::Container.new }

  it "disallows re-registering a factory" do
    container.register(:foo, factory: Hash)
    expect {
      container.register(:foo, factory: Array)
    }.must_raise(ArgumentError)
  end

  it "instantiates class when looking up a class factory" do
    container.register(:hash, factory: Hash)
    _(container.lookup(:hash)).must_be_instance_of Hash
  end

  it "calls callable when looking up a callable factory" do
    obj = {}
    container.register(:hash, factory: proc { obj } )
    _(container.lookup(:hash)).must_be_same_as obj
  end

  it "calls callable when looking up a callable factory registered with a block" do
    obj = {}
    container.register(:hash) { obj }
    _(container.lookup(:hash)).must_be_same_as obj
  end

  it "returns nil when looking up something that hasn't been registered" do
    _(container.lookup(:unregistered)).must_be_nil
  end

  it "caches instance when looking up multiple times" do
    container.register(:hash, factory: Hash )
    _(container.cached?(:hash)).must_equal false
    obj = container.lookup(:hash)
    _(container.cached?(:hash)).must_equal true
    _(container.lookup(:hash)).must_be_same_as obj
  end

end
