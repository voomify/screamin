module Screamin
  module Jobs
    class Discover
      def initialize(config)
        @config = config
        @provider = find_provider(config.provider)
      end

      def require_provider
        require_relative "#{@provider}_provider"
      end

      def instance
        Object.const_get("Screamin::Jobs::#{@provider.to_s.capitalize}Provider").new(@config.options)
      end
      private
      def find_provider(provider)
        return provider if provider
        return :sidekiq if defined?(Sidekiq)
        return :activejob if defined?(ActiveJob)
        raise Errors::ConfigurationError, 'Unable to discover a default job provider! '\
                                          'You must either have the sidekiq or activejob gem installed.'
      end
    end
  end
end

Screamin::Jobs::Discover.new(Screamin.config.jobs).require_provider
