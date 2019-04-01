require 'rack/utils'
require 'forwardable'

module Screamin
  # Tracks all requests for analysis
  # From analysis a user can build a caching policy by turning on or off caching for given method:route:[]key:value,...]
  class Analysis
    attr_reader :host, :path, :request_method, :status, :count

    def initialize(last_req_tracking, trace)
      req = Rack::Request.new(trace.request.headers)
      @path = req.path
      @host = trace.host
      @request_method = trace.request_method
      @count = (last_req_tracking&.count || 0) + 1
      @status = last_req_tracking&.status || {}
      hashes = @status.fetch(trace.status) {h = {}; @status[trace.status] = h; h}
      last_cachable_request = hashes.fetch(trace.hash) {nil}
      hashes[trace.hash] = CachableRequest.new(last_cachable_request, trace)
    end

    def session
      {}
    end

    def query_string
      ""
    end

    def has_header?(key)
      headers.has_key?(key)
    end

    def headers
      {}
    end

    def score
      count #/ @hashes.size
    end

    # A request tracks all the requests that return the same response results
    # It tracks the hits, time span between first and last, the average_duration of the last two requests
    class CachableRequest
      extend Forwardable

      attr_reader :hash, :status
      attr_reader :hits, :first_at, :last_at, :average_duration

      attr_reader :request
      def_delegators :request, :request_method, :query_params, :cookies, :session
      def_delegator :request, :headers, :request_headers

      attr_reader :response
      def_delegator :response, :headers, :response_headers

      def initialize(last_cachable_request, trace)
        @hash = trace.response.hash
        @status = trace.response.status
        @hits = (last_cachable_request&.hits || 0) + 1
        @first_at = last_cachable_request&.first_at || trace.response.time
        @last_at = trace.response.time
        @request = Request.new(last_cachable_request&.request, trace.request)
        @response = Response.new(last_cachable_request&.response, trace.response)
      end

      def query_string
        Rack::Utils.build_nested_query(query_params)
      end

      def headers
        request_headers
      end

      def has_header?(key)
        headers.has_key?(key)
      end


      class Request
        attr_reader :request_method, :query_params, :headers, :cookies, :session

        def initialize(last_request, trace_request)
          req = Rack::Request.new(trace_request.headers)
          @request_method = req.request_method
          @query_params = prepare_params(last_request&.query_params, prepare_query_params(req.query_string))
          @headers = prepare_params(last_request&.headers, filter_headers(trace_request.headers))
          @cookies = prepare_params(last_request&.cookies, req.cookies)
          @session = prepare_params(last_request&.session, trace_request.session)
        end


        private

        def prepare_query_params(query_string)
          Rack::Utils.parse_nested_query(query_string)
        end

        def filter_headers(headers)
          Hash[*(headers).select {|k, v| k.start_with? 'HTTP_'}
                    .reject {|k, _| k == 'Cookie'}
                    .sort
                    .flatten]
        end

        def prepare_params(last_params, current_params)
          lh = last_params || {}
          current_params.map {|k, v| [k, RequestParam.new(lh.fetch(k) {nil}, value: v)]}.to_h
        end
      end

      class Response
        attr_reader :headers

        def initialize(last_response, trace_response)
          @headers = prepare_headers(last_response&.headers, trace_response.headers)
        end

        def prepare_headers(last_headers, headers)
          lh = last_headers || {}
          headers.map {|k, v| [k, RequestParam.new(lh.fetch(k) {nil}, value: v)]}.to_h
        end

      end

      private

      class RequestParam
        attr_reader :values, :hits
        attr_accessor :cache_key
        alias cache_key? cache_key

        def initialize(last_req_param, value:)
          @hits = (last_req_param&.hits || 0) + 1
          @values = last_req_param&.values || []
          @values << value
          @values.uniq!
          @cache_key = false
        end

        def relevance
          @values.size.to_f / @hits
        end
      end

      # def difference(what, other)
      #   return {} unless send(what)
      #   return send(what) unless other.send(what)
      #   send(what).reject do |k, v|
      #     other.send(what).has_key?(k) && other.send(what)[k] == v
      #   end
      # end
    end
  end
end
