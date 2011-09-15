=begin
Use this Rack middleware after your DataMapper repositories have been set up.

It will ensure the binding to master is reset at the end of every request.

    use DataMapper::MasterSlaveAdapter::Middleware::WriteUnbinding, :your_repository

If you are using Rails, it is possible to do this from inside of your ApplicationController.
=end
module DataMapper
  module MasterSlaveAdapter
    module Middleware

      class WriteUnbinding
        def initialize(app, name = :default)
          @app  = app
          @name = name.to_sym
        end

        def call(env)
          @app.call(env)
        ensure
          adapter = DataMapper.repository(@name).adapter
          adapter.reset_binding if adapter.respond_to?(:reset_binding)
        end
      end

    end
  end
end
