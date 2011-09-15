require 'spec_helper'

describe DataMapper::MasterSlaveAdapter::Middleware::WriteUnbinding do
  let(:app)        { double(:call => nil) }
  let(:env)        { stub() }
  let(:middleware) { DataMapper::MasterSlaveAdapter::Middleware::WriteUnbinding.new(app, :test) }
  let(:adapter)    { double(:reset_binding => nil) }

  before(:each) do
    DataMapper.should_receive(:repository).with(:test).and_return(stub(:adapter => adapter))
  end

  it "invokes the application" do
    app.should_receive(:call).with(env)
    middleware.call(env)
  end

  it "resets the adapter binding at the end of the request" do
    adapter.should_receive(:reset_binding)
    middleware.call(env)
  end

  it "ensures the binding is reset when an error occurs" do
    app.stub(:call) { raise "An error" }
    adapter.should_receive(:reset_binding)
    middleware.call(env) rescue Exception
  end
end
