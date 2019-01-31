require 'screamin/helpers/keys'

module Screamin
  class Cache
    include Screamin::KeyHelpers

    def initialize(storage, app_name, app_env, ttl:60)
      @storage = storage
      @app_name = app_name
      @app_env = app_env
      @ttl = ttl
    end

    def fetch(key, options = {}, &block)
      full_key = build_key(key)
      if @storage.key?(full_key)
        data,time = @storage.get(full_key)
        [data, Time.now-time]
      else
        data = block.call
        @storage.set(full_key, [data,Time.now], options.fetch(:expires_in){@ttl})
        [data,0]
      end
    end

    private
    def build_key(*k)
      super(@app_name, @app_env, :cache, *k)
    end
  end
end
