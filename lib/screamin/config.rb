require 'dry-configurable'

module Screamin
  extend Dry::Configurable
  DEFAULT_BATCH_SIZE = 10
  DEFAULT_EXPIRATION = 60

  setting :policy do
    setting :default_expiration, Integer(ENV['SCREAMIN_DEFAULT_EXPIRATION'] || DEFAULT_EXPIRATION)
  end
  setting :analysis do
    # Controls what environments are available to be analyzed
    setting :environments, ['production', 'development']
    setting :batch_size, Integer(ENV['SCREAMIN_BATCH_SIZE'] || DEFAULT_BATCH_SIZE)
  end
  setting :storage do
    setting :provider # :memcached or :redis
    setting :options
  end
  setting :jobs do
    setting :provider # :sidekiq or :activejob
    setting :options
    setting :queue, :screamin
  end
  setting :app do
    setting :name, ENV['SCREAMIN_APP_NAME'] # The name of the app. Automatically uses Rails app name if running Rails.
    setting :env, ENV['RACK_ENV'] # The envirnoment the app is running in. Automatically uses Rails.env if running Rails.
  end
end
