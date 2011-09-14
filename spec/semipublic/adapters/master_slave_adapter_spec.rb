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

  context "configured with an options hash" do
    before(:each) do
      @master = double()
      @slave  = double()
    end

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
    before(:each) do
      @master = double()
      @master.should_receive(:kind_of?).with(DataMapper::Adapters::AbstractAdapter).and_return(true)
      @slave = double()
      @slave.should_receive(:kind_of?).with(DataMapper::Adapters::AbstractAdapter).and_return(true)
    end

    it "uses the provided adapters directly" do
      adapter = DataMapper::Adapters::MasterSlaveAdapter.new(:test, {
        :master => @master,
        :slave  => @slave
      })

      adapter.master.should be(@master)
      adapter.slave.should be(@slave)
    end
  end
end
