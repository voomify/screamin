# frozen_string_literal: true
require 'screamin/version'
require 'json'
require 'digest'
require 'net/http'
require 'bigdecimal'
require_relative 'config'
require_relative 'errors'
require_relative 'cache'
require_relative 'debug'

require_relative 'jobs/discover'
require_relative 'entities/policy'
require_relative 'entities/app'

require_relative 'repository/app'
require_relative 'repository/analysis'
require_relative 'repository/policy'

require_relative 'helpers/environment'

module Screamin
  class Middleware
    include Screamin::Debug
    include Screamin::Storage
    include Screamin::Helpers::Environment
    include Screamin::Helpers::AppName

    ALLOWED_VALUE_TYPES = [NilClass, TrueClass, FalseClass, String, Integer, Float, BigDecimal, Array, Hash]

    def initialize(rack_app)
      @rack_app = rack_app
      @traces = []
      @trace_mutex = Mutex.new
      @batch_size = Screamin.config.analysis.batch_size
      debug "Initialized Screamin::Middleware with SCREAMIN_BATCH_SIZE=#{@batch_size}"
      register_app
    end

    def call(env)
      req = Rack::Request.new(env)
      traces = []
      trace_request = collect_data?
      traces << [Time.now, prepare_headers(req.env), prepare_session(req.session)] if trace_request
      result, cache_hit = fetch(req)
      output = String.new
      result[2].each do |part|
        next if part.bytesize.zero?
        output << part
      end

      debug '==============================================',
            output,
            '=============================================='

      if trace_request
        traces << [Time.now, cache_hit, result[0], result[1], Digest::MD5.hexdigest(output)]
        analyze(traces)
      end
      result
    end

    def self.call(app)
      new(app)
    end

    private

    def register_app
      @app = (app_repo(storage).app(app_name) || Screamin::App.new(app_name)).add_env(app_env)
      app_repo(storage).save!(@app)
    end

    def prepare_headers(env)
      env.select {|_, v| ALLOWED_VALUE_TYPES.include?(v.class)}
    end

    def add_response_headers(headers, hit_or_miss, age)
      h = headers.merge('X-Cache' => hit_or_miss)
      h = h.merge!('Age' => age) unless age.nil?
      h
    end

    def prepare_session(session)
      session.respond_to?(:to_hash) ? session.to_hash : session.to_h
    end

    def fetch(req)
      fetch_from_cache(req)
    end

    def fetch_from_cache(req)
      cache_hit = :HIT
      response, age = policy.fetch(cache, req) do
        cache_hit = :MISS
        rack_response = fetch_from_backend(req)
        [rack_response[0], prepare_headers(rack_response[1]), prepare_body(rack_response[2])]
      end
      [[response[0], add_response_headers(response[1], cache_hit, age), response[2]], cache_hit]
    end

    def prepare_body(body)
      cachable_response = []
      body.each do |s|
        cachable_response << s
      end
      cachable_response
    end

    def fetch_from_backend(req)
      @rack_app.call(req.env)
    end

    def analyze(traces)
      @trace_mutex.synchronize do
        @traces.push traces
      end
      if @traces.size > @batch_size
        Thread.start do
          traces = nil
          @trace_mutex.synchronize do
            traces = @traces.dup
            @traces.clear
          end
          jobs.queue(traces)
        end
      end
    end

    def cache
      @cache ||= Cache.new(storage, app_name, app_env)
    end

    def jobs
      @jobs ||= Screamin::Jobs::Discover.new(Screamin.config.jobs).instance
    end

    def collect_data?
      collect_for_current_env? && analysis_repo(storage).collect_data?
    end

    def analysis_repo(storage)
      @analysis_repo ||= Repository::Analysis.new(storage, app_name, app_env)
    end

    def app_repo(storage)
      @app_repo ||= Repository::App.new(storage)
    end

    def policy_repo(storage)
      @policy_repo ||= Repository::Policy.new(storage, app_name, app_env)
    end

    def policy
      policy_repo(storage).policy
    end
  end
end
