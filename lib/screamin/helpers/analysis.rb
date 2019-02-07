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
      include Voom::Presenters::Helpers::Inflector

      def key
        context[:key]
      end

      def hash
        context[:hash]
      end

      def status_code
        Integer(context[:status_code]) if context[:status_code]
      end

      def hash_tracking(h = hash, sc = status_code)
        (request_tracking&.status || {}).dig(sc, h)
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

      def strategy
        @strategy ||= policy.request_strategy(request_tracking&.host, request_tracking&.request_method, request_tracking&.path)
      end

      def unique_request_cached?(hash_tracking = self.hash_tracking)
        strategy&.matches?(hash_tracking)
      end
    end
  end
end
