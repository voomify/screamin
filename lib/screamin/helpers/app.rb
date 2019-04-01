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

      def bullets
        body (<<~TEXT), id: :bullets
          * **Speeds up** your app, on between **1.5x and 12x**
          * **30 second setup** (3 lines of code)
          * Monitors your application and **automatically** analyzes traffic
          * You **point and click** and create a caching policy
          * **Requires no code changes** to the app to change caching behavior
          * Allows you to focus on **adding features**
        TEXT
      end
    end
  end
end
