require 'spec_helper'

describe DataMapper::Adapters::MasterSlaveAdapter do
  before(:each) do
    @master = double(:kind_of? => true)
    @slave  = double(:kind_of? => true)
    @args   = stub()
    @result = stub()

    @adapter = DataMapper::Adapters::MasterSlaveAdapter.new(:test, {
      :master => @master,
      :slave  => @slave
    })
  end

  context "delegation" do
    it "sends all reads to the slave" do
      @slave.should_receive(:read).with(@args).and_return(@result)
      @adapter.read(@args).should be(@result)
    end

    it "sends aggregate queries to the slave" do
      @slave.should_receive(:aggregate).with(@args).and_return(@result)
      @adapter.aggregate(@args).should be(@result)
    end

    it "sends create to the master" do
      @master.should_receive(:create).with(@args).and_return(@result)
      @adapter.create(@args).should be(@result)
    end

    it "sends update to the master" do
      @master.should_receive(:update).with(@args).and_return(@result)
      @adapter.update(@args).should be(@result)
    end

    it "sends destroy to the master" do
      @master.should_receive(:destroy).with(@args).and_return(@result)
      @adapter.destroy(@args).should be(@result)
    end

    it "sends any unknown method to the master" do
      @master.should_receive(:prepare_statement).with(@args).and_return(@result)
      @adapter.prepare_statement(@args).should be(@result)
    end

    it "provides direct access to the master" do
      @adapter.master.should == @master
    end

    it "provides direct access to the slave" do
      @adapter.slave.should == @slave
    end
  end

  describe "#kind_of?" do
    it "returns true if kind matches itself" do
      @adapter.kind_of?(DataMapper::Adapters::MasterSlaveAdapter).should be_true
    end

    it "delegates to the master if kind does not match itself" do
      @master.should_receive(:kind_of?).with(String).and_return(false)
      @adapter.kind_of?(String).should be_false
    end
  end

  describe "state" do
    it "allows binding reads to the master" do
      @adapter.bind_to_master
      @master.should_receive(:read).with(@args).and_return(@result)
      @adapter.read(@args).should be(@result)
    end

    it "reports if it is bound to master" do
      @adapter.bind_to_master
      @adapter.should be_bound_to_master
    end

    it "binds all reads to the master after the first write" do
      @master.should_receive(:update)
      @master.should_receive(:read).with(@args).and_return(@result)
      @adapter.update(stub())
      @adapter.read(@args).should be(@result)
    end

    it "can be unbound from master" do
      @adapter.bind_to_master
      @adapter.reset_binding
      @slave.should_receive(:read).with(@args).and_return(@result)
      @adapter.read(@args).should be(@result)
    end

    it "does not remain bound to master when using the adapter directly" do
      @master.stub(:execute => nil)
      @adapter.master.execute(stub())
      @adapter.should_not be_bound_to_master
    end

    it "can be bound to master in the context of a block" do
      @master.should_receive(:read).with(@args).and_return(@result)
      @adapter.bind_to_master do
        @adapter.read(@args).should be(@result)
      end
      @adapter.should_not be_bound_to_master
    end

    it "does not unbind from master after binding for a block if it was already bound before the block" do
      @adapter.bind_to_master
      @master.should_receive(:read).with(@args).and_return(@result)
      @adapter.bind_to_master do
        @adapter.read(@args).should be(@result)
      end
      @adapter.should be_bound_to_master
    end
  end

  context "configured with an options hash" do
    it "delegates to DataMapper::Adapters to create a master and a slave of the same name" do
      DataMapper::Adapters.should_receive(:new).with(:test, { :adapter => :test_slave }).and_return(@slave)
      DataMapper::Adapters.should_receive(:new).with(:test, { :adapter => :test_master }).and_return(@master)

      adapter = DataMapper::Adapters::MasterSlaveAdapter.new(:test, {
        :master => { :adapter => :test_master },
        :slave  => { :adapter => :test_slave }
      })

      adapter.master.should be(@master)
      adapter.slave.should be(@slave)
    end
  end

  context "configured with already instantiated adapters" do
    it "uses the provided adapters directly" do
      @master.should_receive(:kind_of?).with(DataMapper::Adapters::AbstractAdapter).and_return(true)
      @slave.should_receive(:kind_of?).with(DataMapper::Adapters::AbstractAdapter).and_return(true)

      adapter = DataMapper::Adapters::MasterSlaveAdapter.new(:test, {
        :master => @master,
        :slave  => @slave
      })

      adapter.master.should be(@master)
      adapter.slave.should be(@slave)
    end
  end
end
