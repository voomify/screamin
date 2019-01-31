require 'active_job'
require 'screamin/jobs/analyze_requests'
require_relative '../helpers/app'

module Screamin
  module Jobs
    class ActivejobProvider
      include Helpers::AppName

      def initialize(options)
        @options = options || {}
      end

      def queue(requests)
        Analyze.set(queue:queue_name).perform_later(requests, app_name, app_env)
      end

      class Analyze < ActiveJob::Base
        def perform(requests, app_name, app_env)
          AnalyzeRequests.new(requests, app_name: app_name, app_env: app_env).process
        end
      end

      private

      def queue_name
        @options.fetch(:queue){ :screamin }
      end
    end
  end
end
