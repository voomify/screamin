require 'rails'
require 'screamin/middeware'

module Screamin
  module Init
    module Rails
      class Railtie < ::Rails::Railtie
        initializer 'screamin.install_middleware' do |app|
          app.config.middleware.use(Screamin::Middleware)
        end
      end
    end
  end
end

