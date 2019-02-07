module Screamin
  module Helpers
    # Used by tracing to identify app and env for trace data - should not be used by web client
    module AppName
      def app_name
        return Rails.application.class.parent_name if defined?(Rails)
        app_name = Screamin.config.app.name
        raise Screamin::Errors::ConfigurationError, <<~EOS unless app_name
          Unable to determine application name.
          Please define the application name:  

          either 
            export SCREAMIN_APP_NAME=YourAppName 
          or
            Screamin.configuration do |config|
              config.app.name = 'YourAppName'
            end
        EOS
        app_name
      end

      def app_env
        return Rails.env.to_s if defined?(Rails)
        app_env = Screamin.config.app.env

        raise Screamin::Errors::ConfigurationError, <<~EOS unless app_env
          Unable to determine application enviornment.
          Please define the application env:  

          either 
            export RACK_ENV=development
          or
            Screamin.configuration do |config|
              config.app.env = 'development'
            end
        EOS
      end
    end
  end
end
