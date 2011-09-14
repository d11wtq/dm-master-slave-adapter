require 'spec_helper'

describe DataMapper::Adapters::ReaderPoolAdapter do
  before(:each) do
    @random_number = double()
    Random.stub(:new).and_return(@random_number)

    @delegate_a = double(:delegate_a, :kind_of? => true)
    @delegate_b = double(:delegate_b, :kind_of? => true)
    @args       = stub()
    @result     = stub()

    @adapter = DataMapper::Adapters::ReaderPoolAdapter.new(:test, {
      :pool => [@delegate_a, @delegate_b]
    })
  end

  context "delegation" do
    # FIXME: I think probably we should just raise an exception on anything by read/aggregate
    it "sends CRUD operations to a random adapter from the pool" do
      @random_number.should_receive(:rand).exactly(4).times.and_return(1)
      @delegate_b.should_receive(:create).with(@args).and_return(@result)
      @delegate_b.should_receive(:read).with(@args).and_return(@result)
      @delegate_b.should_receive(:update).with(@args).and_return(@result)
      @delegate_b.should_receive(:delete).with(@args).and_return(@result)
      @adapter.create(@args).should be(@result)
      @adapter.read(@args).should be(@result)
      @adapter.update(@args).should be(@result)
      @adapter.delete(@args).should be(@result)
    end

    it "sends aggregate queries to a random adapter from the pool" do
      @random_number.should_receive(:rand).once.and_return(0)
      @delegate_a.should_receive(:aggregate).with(@args).and_return(@result)
      @adapter.aggregate(@args).should be(@result)
    end

    it "sends unknown methods to a random adapter from the pool" do
      @random_number.should_receive(:rand).once.and_return(0)
      @delegate_a.should_receive(:select).with(@args).and_return(@result)
      @adapter.select(@args).should be(@result)
    end
  end

  context "configured with an options hash" do
    it "delegates to DataMapper::Adapters to create a pool of readers of the same name" do
      DataMapper::Adapters.should_receive(:new).with(:test, { :adapter => :test_adapter }).and_return(@delegate_a)

      adapter = DataMapper::Adapters::ReaderPoolAdapter.new(:test, {
        :pool => [{ :adapter => :test_adapter }]
      })

      adapter.pool.should include(@delegate_a)
    end
  end

  context "configured with already instantiated adapters" do
    it "uses the adapters directly" do
      @delegate_a.should_receive(:kind_of?).with(DataMapper::Adapters::AbstractAdapter).and_return(true)
      @delegate_b.should_receive(:kind_of?).with(DataMapper::Adapters::AbstractAdapter).and_return(true)

      adapter = DataMapper::Adapters::ReaderPoolAdapter.new(:test, {
        :pool => [@delegate_a, @delegate_b]
      })

      adapter.pool.should include(@delegate_a)
      adapter.pool.should include(@delegate_b)
    end
  end
end
