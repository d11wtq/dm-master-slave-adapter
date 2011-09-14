require 'forwardable'

module DataMapper
  module Adapters

    class ReaderPoolAdapter < AbstractAdapter
      extend Forwardable

      attr_reader :pool

      def_delegators :random_adapter, :create, :read, :update, :delete

      def initialize(name, options)
        super

        assert_kind_of 'options', @options[:pool], Array

        raise ArgumentError, "The are no adapters in the adapter pool" if @options[:pool].empty?

        @pool = []
        @options[:pool].each do |adapter_options|
          adapter = if adapter_options.kind_of?(AbstractAdapter)
            adapter_options
          else
            assert_kind_of 'pool_adapter_options', adapter_options, Hash
            Adapters.new(name, adapter_options)
          end

          @pool.push(adapter)
        end

        @number_generator = Random.new
      end

      def method_missing(meth, *args, &block)
        random_adapter.send(meth, *args, &block)
      end

      private

      def random_adapter
        @pool[@number_generator.rand(0...@pool.length)]
      end
    end

    const_added(:ReaderPoolAdapter)
  end
end
