require_relative 'commands'
require 'screamin/helpers/app'
require 'screamin/entities/analysis'
require 'screamin/repository/analysis'
require 'screamin/storage'
require_relative 'policy'

module Screamin
  module Helpers
    module Analysis
      include Helpers::Commands
      include Helpers::App
      include Helpers::Policy

      def key
        context[:key]
      end

      def hash
        context[:hash]
      end

      def hash_tracking(h = hash, sc = status_code)
        @hash_tracking ||= request_tracking.status[sc][h]
      end

      def request_tracking(k = key)
        @request_tracking ||= analysis_repo.request(k)
      end

      def analysis_empty?
        !analysis_repo.requests.any?
      end

      def analysis_repo
        @analysis_repo ||= Repository::Analysis.new(storage, app_name, env_name)
      end

      def collect_data?
        analysis_repo.collect_data?
      end

      def requests
        @requests ||= analysis_repo.requests
      end
    end
  end
end
