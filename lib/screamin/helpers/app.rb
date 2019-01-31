require 'screamin/entities/app'
require 'screamin/repository/app'
require 'screamin/storage'

module Screamin
  module Helpers
    module App
      include Storage

      def app_name
        context['app_name']
      end

      def env_name
        context['env_name']
      end

      def apps
        app_repo.apps
      end

      def app(app_name = self.app_name)
        app_repo.app(app_name)
      end

      def app_repo(storage = self.storage)
        @app_repo ||= Repository::App.new(storage)
      end
    end
  end
end
