# DataMapper Master/Slave Adapter (for MySQL replication etc)

This DataMapper adapter provides a thin layer infront of at least two
real DataMaper adapters, splitting reads and writes between a 'master'
and a 'slave'.

The adapter comes in two parts:

  1. The MasterSlaveAdapter, which knows of only two 'real' adapters
  2. A ReaderPoolAdapter, which knows of any number of 'real' adapters
     to use as readers.  You can set the ReaderPoolAdapter as the reader
     for the MasterSlaveAdapter.


## Installation

Via rubygems:

    gem install dm-master-slave-adapter


## Usage

The adapter is configured, at a basic level in the following way:

``` ruby
DataMapper.setup(:default, {
  :adapter => :master_slave,
  :master  => {
    :adapter  => :mysql,
    :host     => "master.db.site.com",
    :username => "root",
    :password => ""
  },
  :slave   => {
    :adapter  => :mysql,
    :host     => "slave.db.site.com",
    :username => "root",
    :password => ""
  }
})

Here we create a repository named :default, which uses MySQL adapters for the
master and the slave.

In YAML, this looks like this:

``` yaml
default:
  adapter: master_slave
  master:
    adapter: mysql
    host: "master.db.site.com"
    username: root
    password: 
  slave:
    adapter: mysql
    host: "slave.db.site.com"
    username: root
    password: 
```

Both the master and the slave are named :default, but you cannot access them directly
with DataMapper.repository( ... ); you can only access the MasterSlaveAdapter.

It is possible to access both the master and the slave using accessors on the
MasterSlaveAdapter, however:

``` ruby
DataMapper.repository(:default).adapter.master
DataMapper.repository(:default).adapter.slave
```

### Bind to master on first write

It is important to note one particular behaviour with this adapter.  By design, after
the first write operation has occurred, all subsquent queries, including reads, will
be sent directly to the master.  This is almost always the desirable behaviour, since
you will undoubtedly experience race conditions due to reader-lag if not.

You can force the binding to the master at any time, using:

``` ruby
DataMapper.repository(:default).adapter.bind_to_master
```

This is a state changing method and will remain in effect until you reset the binding
with:

``` ruby
DataMapper.repository(:default).adapter.reset_binding
```

In a web application, you'll typically want to reset the binding to master at the end
of each request, to ensure subsquent requests are not permanently bound to the master. A
Rack middleware is provided to do this automatically.  The easiest way to use this in a
Rails application, is to mount it inside your ApplicationController:

``` ruby
class ApplicationController < ActionController::Base
  use DataMapper::MasterSlaveAdapter::Middleware::WriteUnbinding, :default
end
```

You can use the middleware anywhere a Rack middleware can be used, however, but it must
be executed after DataMapper has been initialized.

Note that accessing the master directly, (again, by design) will not cause all subsquent
queries to be sent to the master in the same way implicit querying does.  This is useful
when logic is isolated to a specific part of your application and you know other parts of
the application need not query the same storage backend.  I personally do this for
session storage.

Lastly, you can force all queries to be implicitlty sent to the master in the context of
a block, simply by passing a block to #bind_to_master, like so:

``` ruby
DataMapper.repository(:default).adapter.bind_to_master do
  ...
end
```

Once the block has completed, the adapter will be restored to its original state,
regardless of what writes may have occurred.  Note that if the adapter was already
implictly bound to master before the block was invoked, this will have no effect.


### Using the ReaderPoolAdapter

The ReaderPoolAdapter simply allows you to use more than one adapter as the 'slave' when
configuring the MasterSlaveAdapter.  For every read query it receives, it picks a random
adapter from its pool.

It is configured like so:

``` ruby
DataMapper.setup(:default, {
  :adapter => :master_slave,
  :master  => {
    ...
  },
  :slave   => {
    :adapter  => :reader_pool,
    :pool => [
      {
        :adapter  => :mysql
        :host     => "slave1.db.site.com",
        :username => "root",
        :password => ""
      },
      {
        :adapter  => :mysql
        :host     => "slave2.db.site.com",
        :username => "root",
        :password => ""
      }
    ]
  }
})
```

In the above setup, we simply have two MySQL hosts specified as available
slaves to the MasterSlaveAdapter.  In YAML, that looks like this:

``` yaml
default:
  adapter: master_slave
  master:
    ...
  slave:
    adapter: reader_pool
    pool:
      - adapter: mysql
        host: "slave1.db.site.com"
        username: root
        password: 
      - adapter: mysql
        host: "slave2.db.site.com"
        username: root
        password: 
```

## Reporting Issues

Please file any issues in the issue tracker at GitHub:

  - https://github.com/d11wtq/dm-master-slave-adapter/issues

## Potential TODOs

  - Raise an exception for #create, #update and #delete on the reader
  - Enhanced logging to include the details of the adapter being used

## Copyright and Licensing

Copyright © 2011 Chris Corbyn

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
