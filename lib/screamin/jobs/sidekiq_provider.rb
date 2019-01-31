require 'sidekiq'
require 'screamin/jobs/analyze_requests'
require_relative '../helpers/app_name'


module Screamin
  module Jobs
    class SidekiqProvider
      include Helpers::AppName
      def initialize(options)
        @options = options || {}
      end

      def queue(requests)
        Analyze.set(queue: queue_name).perform_async(requests, app_name, app_env)
      end

      class Analyze
        include Sidekiq::Worker

        def perform(requests, app_name, env_name)
          AnalyzeRequests.new(requests, app_name: app_name, env_name: env_name).process
        end
      end

      private

      def queue_name
        @options.fetch(:queue) {:screamin}
      end
    end
  end
end
