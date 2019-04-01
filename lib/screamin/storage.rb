require 'prefatory/storage/discover'
require 'prefatory/config'

# Map prefatory storage key prefix into screamin
Prefatory.config.keys.prefix = 'screamin'

module Screamin
  module Storage
    def storage
      @storage ||= Prefatory::Storage::Discover.new(Screamin.config.storage).instance
    end
  end
end
