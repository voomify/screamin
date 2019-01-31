require_relative 'config'
require_relative 'errors'
require 'rack/static'

require 'voom-presenters'
require 'voom/presenters/web_client/app'
# load commands
Dir[File.expand_path('./routes/*.rb', __dir__)].each {|file| require file}

module Screamin
  class Web < Voom::Presenters::WebClient::App
    use Rack::Static, :urls => ["/screamin/images"],
        :root => File.join(File.expand_path('../../', __dir__), 'app', 'web', 'public')
    Screamin::Routes.constants.each do |route|
      use Screamin::Routes.const_get(route)
    end

  end
end

Voom::Presenters::Settings.configure do |config|
  config.presenters.root = File.join(File.expand_path('../../', __dir__), 'app')
end
Voom::Presenters::App.boot!

