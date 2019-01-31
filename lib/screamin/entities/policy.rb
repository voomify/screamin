module Screamin
  # A policy defines the caching policy
  # The middleware uses it to determine what items should be cached
  class Policy
    DEFAULT_EXPIRATION = {expires_in: Screamin.config.policy.default_expiration}
    attr_reader :active, :version, :strategies, :last_revised_at
    alias active? active

    def initialize(bump_revision_ = true)
      @active = true
      @strategies = {}
      @version = 0
      bump_revision if bump_revision_
    end

    def toggle_active
      @active = !@active
      self
    end

    def add_path_strategy(method, path, query_keys: {}, header_keys: {}, session_keys: {}, options: DEFAULT_EXPIRATION)
      strategy = CacheStrategy.new(CacheKey.new(method, path, query_keys: query_keys,
                                                header_keys: header_keys, session_keys: session_keys),
                                   options: options)
      @strategies[strategy.key] = strategy
      bump_revision
      self
    end

    def remove_path_strategy(method, path)
      @strategies.delete([method, path])
      bump_revision
      self
    end

    def fetch(cache, req, &block)
      strategy_ = strategy(req)
      return [yield, nil] unless active && strategy_

      strategy_.fetch(cache, &block)
    end

    def strategy(req)
      strategy_ = request_strategy(req.request_method, req.path)
      return nil unless strategy_&.active
      strategy_&.matches?(req) ? strategy_ : nil
    end

    def request_strategy(*key)
      @strategies.fetch(key) {nil}
    end

    class CacheStrategy
      attr_reader :cache_key, :active, :options
      alias active? active

      def initialize(cache_key, cache_options = {expires_in: 60})
        @active = true
        @cache_key = cache_key
        @options = cache_options
      end

      def key
        [@cache_key.method, @cache_key.path]
      end

      def toggle_active
        @active = !@active
        self
      end

      def matches?(req)
        @cache_key.matches?(req)
      end

      def fetch(cache, &block)
        cache.fetch(@cache_key.key, @options, &block)
      end
    end

    class CacheKey
      attr_reader :method, :path, :query_keys, :header_keys, :session_keys

      def initialize(method, path, query_keys: {}, header_keys: {}, session_keys: {})
        @method = method
        @path = path
        @query_keys = Hash(query_keys.sort)
        @header_keys = Hash(header_keys.sort)
        @session_keys = Hash(session_keys.sort)
      end

      def matches?(req)
        req_query_params = Rack::Utils.parse_nested_query(req.query_string)
        req.request_method == @method &&
            req.path == @path &&
            @query_keys.reject {|k, v| req_query_params[k] == v}.none? &&
            @header_keys.reject {|k, v| req.headers[k] == v}.none? &&
            @session_keys.reject {|k, v| req.session[k] == v}.none?
      end

      def key
        [@method, @path, @query_keys, @header_keys, @session_keys]
      end
    end


    private

    def bump_revision
      @version += 1
      @last_revised_at = Time.now
    end

    def self.keys
      @keys ||= Keys.new
    end
  end
end
