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
    end

    def add_strategy(domain, method, path, options: DEFAULT_EXPIRATION, **cache_keys)
      strategy = CacheStrategy.new(domain, method, path, options: options)
      strategy.add_cache_key(**cache_keys) if cache_keys.any?
      @strategies[strategy.key] = strategy
      bump_revision
      strategy
    end

    def remove_strategy(domain, method, path)
      strategy = @strategies.delete([domain, method, path])
      bump_revision
      strategy
    end

    def fetch(cache, req, &block)
      strategy_ = strategy(req)
      return [yield, nil] unless active && strategy_

      strategy_.fetch(cache, req, &block)
    end

    def strategy(req)
      strategy_ = request_strategy(req.host_with_port, req.request_method, req.path)
      return nil unless strategy_&.active
      strategy_&.matches?(req) ? strategy_ : nil
    end

    def request_strategy(*key)
      @strategies.fetch(key) {nil}
    end

    class CacheStrategy
      attr_reader :host, :method, :path, :active, :options
      # Each Cache key instance represents an OR condition
      attr_reader :cache_keys
      alias active? active

      def initialize(host, method, path, options:)
        @host = host
        @method = method
        @path = path
        @options = options
        @active = true
        @cache_keys = []
      end

      def add_cache_key(cache_key)
        @cache_keys << CacheKey.new(**cache_key)
      end

      def has_key?(collection, key)
        @cache_keys.any? do |ck|
          ck.has_key?(collection, key)
        end
      end

      def key
        [host, method, path]
      end

      def toggle_active
        @active = !@active
        self
      end

      def matches?(req)
        return true if @cache_keys.empty?
        @cache_keys.select do |ck|
          ck.matches?(req)
        end.any?
      end

      def fetch(cache, req, &block)
        cache.fetch(full_request_key(req), @options, &block)
      end

      def full_request_key(req)
        fk = key + @cache_keys.map do |ck|
          ck.key_value(req)
        end
        fk

      end
    end

    class CacheKey
      attr_reader :query_keys, :header_keys, :session_keys, :cookies
      alias request_headers header_keys
      alias query_params query_keys
      alias session session_keys

      def initialize(query_params: [], request_headers: [], session: [], cookies: [])
        @query_keys = query_params.sort
        @header_keys = request_headers.sort
        @session_keys = session.sort
        @cookies = cookies.sort
      end

      def matches?(req)
        req_query_params = Rack::Utils.parse_nested_query(req.query_string)
        @query_keys.reject {|k| req_query_params.has_key?(k)}.none? &&
            @header_keys.reject {|k| req.has_header?(k)}.none? &&
            @session_keys.reject {|k| req.session.has_key?(k)}.none? &&
            @cookies.reject {|k| req.cookies.has_key?(k)}.none?
      end

      def has_key?(collection, key)
        send(collection).include?(key)
      end

      def key_value(req)
        req_query_params = Rack::Utils.parse_nested_query(req.query_string)
        kv = [@query_keys.map {|k| [k,req_query_params.fetch(k)]},
         @header_keys.map {|k| [k,req.get_header(k)]},
         @session_keys.reject {|k| [k,req.session.fetch(k)]},
         @cookies.reject {|k| [k,req.cookies.fetch(k)]}]
        kv
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
