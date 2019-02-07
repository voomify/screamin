if defined?(::Rails::Railtie)
  require_relative 'init/rails'
else
  raise 'Rails is required for Screamin.io! ' \
        'Please submit or upvote an issue at http://github.com/voomify/screamin to get your desired framework/language added.' unless ENV['RACK_ENV']=='test'
end
