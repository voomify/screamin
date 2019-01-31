module Screamin
  module Repository
    class App
      attr_reader :storage
      private :storage

      def initialize(storage)
        @storage = storage
      end

      def apps
        storage.get(build_key(:apps))|| []
      end

      def app(app_name)
        storage.get(build_key(:app, app_name))
      end

      def save!(app)
        apps_ = apps
        apps_ << app.name
        storage.set(:apps, apps_.uniq)
        storage.set(build_key(:app, app.name), app)
      end

      private
      def build_key(*keys)
        keys.join(':')
      end
    end
  end
end
