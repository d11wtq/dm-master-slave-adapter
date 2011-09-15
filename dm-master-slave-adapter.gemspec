# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "data_mapper/master_slave_adapter/version"

Gem::Specification.new do |s|
  s.name        = "dm-master-slave-adapter"
  s.version     = DataMapper::MasterSlaveAdapter::VERSION
  s.authors     = ["Chris Corbyn"]
  s.email       = ["chris@w3style.co.uk"]
  s.homepage    = "https://github.com/d11wtq/dm-master-slave-adapter"
  s.summary     = %q{Master/Slave Adapter for DataMapper}
  s.description = (<<-TEXT)
    Provides the ability to use DataMapper in an environment where
    database replication draws the need for using separate connections
    for reading and writing data.

    This adapter simply wraps two other "real" DataMapper adapters,
    rather than providing any direct I/O logic
  TEXT

  s.rubyforge_project = "dm-master-slave-adapter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency "dm-core"
end
