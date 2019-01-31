require 'screamin/helpers/keys'

module Screamin
  module Repository
    class Analysis
      include KeyHelpers
      attr_reader :storage
      private :storage

      def initialize(storage, app_name, env_name)
        @storage = storage
        @app_name = app_name
        @env_name = env_name.to_s
      end

      def requests
        storage.get(build_key(:requests)) || []
      end

      def request(key)
        storage.get(build_key(key))
      end

      def save_analysis(key, analysis)
        storage.set(build_key(*key), analysis)
        reqs_key = build_key(:requests)
        requests = storage.get(reqs_key) || []
        requests << key
        storage.set(reqs_key, requests.uniq)
      end

      def collect_data?
        storage.get(build_key(:collect_data))
      end

      def toggle_data_collection
        new_state = collect_data? ? false : true
        storage.set(build_key(:collect_data), new_state)
        new_state
      end

      def reset_data!
        requests.each do |key|
          storage.delete(build_key(*key))
        end
        storage.delete(build_key(:requests))
      end

      private

      def build_key(*k)
        super(@app_name, @env_name, :tracking, *k)
      end
    end
  end
end
