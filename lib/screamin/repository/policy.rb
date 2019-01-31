require 'screamin/helpers/keys'
require 'screamin/entities/policy'


module Screamin
  module Repository
    class Policy
      include KeyHelpers
      attr_reader :storage
      private :storage

      def initialize(storage, app_name, env_name)
        @storage = storage
        @app_name = app_name
        @env_name = env_name
      end

      def current
        storage.get(build_key(:current))
      end

      def history
        storage.get(build_key(:history))
      end

      def policy(version=:current)
        storage.get(build_key(version)) || Screamin::Policy.new(false)
      end

      def save!(policy)
        history = storage.get(build_key(:history)) || []
        history << policy.version
        storage.set(build_key(:history), history)
        storage.set(build_key(:current), policy)
        storage.set(build_key(policy.version), policy)
      end

      private

      def build_key(*k)
        super(@app_name, @env_name, :policy, *k)
      end
    end
  end
end
