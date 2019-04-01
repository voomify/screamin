require_relative 'config'
require_relative 'errors'
require 'rack/static'

require 'voom-presenters'
require 'voom/presenters/web_client/app'
# load commands
Dir[File.expand_path('./routes/*.rb', __dir__)].each {|file| require file}

Voom::Presenters::Settings.configure do |config|
  config.presenters.root = File.join(File.expand_path('../../', __dir__), 'app')
  config.presenters.web_client.custom_css= 'public'
end

module Screamin
  class Web < Voom::Presenters::WebClient::App
    use Rack::Static, :urls => ["/screamin/images"],
        :root => File.join(Voom::Presenters::Settings.config.presenters.root, 'public')
    use Rack::Static, :urls => ["/global.css"],
            :root => File.join(Voom::Presenters::Settings.config.presenters.root, 'public')
    Screamin::Routes.constants.each do |route|
      use Screamin::Routes.const_get(route)
    end

  end
end

Voom::Presenters::App.boot!

