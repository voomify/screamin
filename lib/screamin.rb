require "screamin/version"
require "logger"
require 'json'
require 'digest'
require 'net/http'
require 'bigdecimal'

module Screamin
  class Error < StandardError;
  end
  class Fast
    ALLOWED_VALUE_TYPES = [NilClass, TrueClass, FalseClass, String, Integer, Float, BigDecimal, Array, Hash]

    def initialize(rack_app, _key)
      @rack_app = rack_app
      @traces = []
      @trace_mutex = Mutex.new
      # @mutex = Mutex.new
      @cache_policy = {}
      @cache_policy_mutex = Mutex.new
      @batch_size = Integer(ENV['VCS_BATCH_SIZE'] || DEFAULT_BATCH_SIZE)
    end

    def call(env)
      req = Rack::Request.new(env)
      trace = []
      trace << scrubbed_headers(req.env)
      result, cache_hit = fetch(req)
      trace << [cache_hit, result[0], result[1], Digest::MD5.hexdigest(result[2].to_s)]
      post(trace) unless reentrant?(req)
      result
    end

    def self.call(app, key)
      new(app, key)
    end

    private

    TRACE_PATH = '/api/v1/trace'.freeze
    DEFAULT_BATCH_SIZE = 10.freeze
    SUCCESS = '200'.freeze

    def scrubbed_headers(env)
      env.map {|k, v| [k, ALLOWED_VALUE_TYPES.include?(v.class) ? v : v.to_s]}.to_h
    end

    def reentrant?(req)
      req.script_name == TRACE_PATH
    end

    def fetch(req)
      if cachable?(req)
        fetch_from_cache(req)
      else
        [fetch_from_backend(req), :miss]
      end
    end

    def cachable?(req)
      cache_strategy(req) != nil
    end

    def cache_strategy(req)
      strategy = @cache_policy.fetch('strategy'){{}}
      strategy.fetch(cache_key(req)){nil}
    end

    def fetch_from_cache(req)
      cache_hit = :hit
      response = Rails.cache.fetch(cache_key(req), cache_options(req)) do
        cache_hit = :miss
        rack_response = fetch_from_backend(req)
        [rack_response[0],scrubbed_headers(rack_response[1]),prepare_body(rack_response[2])]
      end
      [response, cache_hit]
    end

    def prepare_body(body)
      body.map(&:to_s)
    end

    def fetch_from_backend(req)
      @rack_app.call(req.env)
    end

    def cache_key(req)
      req.fullpath
    end

    def cache_options(req)
      {expires_in: expiration_policy(req)}
    end

    def expiration_policy(req)
      1.minute
    end

    def post(trace)
      @trace_mutex.synchronize do
        @traces.push trace
      end
      if @traces.size > @batch_size
        Thread.start do
          traces = nil
          @trace_mutex.synchronize do
            traces = @traces.dup
            @traces.clear
          end
          update_cache_policy(post_to_vcs(traces))
        end
      end
    end

    def post_to_vcs(traces)
      uri = URI("#{ENV['VCS_HOST'] || 'http://localhost:3000'}/#{TRACE_PATH}")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = traces.to_json
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end

    def update_cache_policy(res)
      if res.code == SUCCESS
        latest_cache_policy = JSON.parse(res.body)
        Rails.logger.info("Screamin.io updated caching policy:#{latest_cache_policy.inspect}") unless @cache_policy == latest_cache_policy
        @cache_policy_mutex.synchronize do
          @cache_policy = latest_cache_policy
        end
      end
    end
  end
end
