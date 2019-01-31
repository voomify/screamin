require 'prefatory/storage/discover'
require 'prefatory/config'

# Map prefatory storage key prefix into screamin
Prefatory.configure do |config|
  config.keys.prefix = 'screamin'
end

module Screamin
  module Storage
    def storage
      @storage ||= Prefatory::Storage::Discover.new(Screamin.config.storage).instance
    end
  end
end
