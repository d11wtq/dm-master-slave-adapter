require 'forwardable'

module DataMapper
  module Adapters

    class MasterSlaveAdapter < AbstractAdapter
      extend Forwardable

      attr_reader :slave
      attr_reader :master

      def_delegators :reader, :read, :aggregate
      def_delegators :writer, :create, :update, :delete

      def initialize(name, options)
        super

        @slave = if @options[:slave].kind_of?(AbstractAdapter)
          @options[:slave]
        else
          assert_kind_of 'options', @options[:slave],  Hash
          Adapters.new(name,  @options[:slave])
        end

        @master = if @options[:master].kind_of?(AbstractAdapter)
          @options[:master]
        else
          assert_kind_of 'options', @options[:master],  Hash
          Adapters.new(name,  @options[:master])
        end

        @reader = @slave
      end

      def bind_to_master
        original_reader, @reader = @reader, @master

        if block_given?
          begin
            yield
          ensure
            @reader = original_reader
          end
        end

        self
      end

      def bound_to_master?
        @reader.equal?(@master)
      end

      def reset_binding
        @reader = @slave
        self
      end

      def kind_of?(kind)
        super || master.kind_of?(kind)
      end

      private

      def reader
        @reader
      end

      def writer
        bind_to_master
        @master
      end

      def method_missing(meth, *args, &block)
        writer.send(meth, *args, &block)
      end
    end

    const_added(:MasterSlaveAdapter)
  end
end
