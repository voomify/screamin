require 'rack/utils'

module Screamin

# A trace wrappers the data that is collected from the middleware and sent to a background job for processing
# This data is turned into analysis by the background job
  class Trace
    attr_reader :request, :response

    def initialize(trace)
      @request = Request.new(trace[0])
      @response = Response.new(trace[1])
    end

    def hash
      response.hash
    end

    def host
      request.host
    end

    def path
      request.path
    end

    def request_method
      request.request_method
    end

    def status
      response.status
    end

    class Request
      attr_reader :time, :headers, :session

      def initialize(trace)
        @time = trace[0]
        @headers = trace[1]
        @session = trace[2]
      end

      def path
        headers['REQUEST_PATH']
      end

      def host
        "#{headers['SERVER_NAME']}:#{headers['SERVER_PORT']}"
      end

      def request_method
        headers['REQUEST_METHOD']
      end
    end

    class Response
      attr_reader :time, :hit, :status, :headers, :hash

      def initialize(trace)
        @time = trace[0]
        @hit = trace[1]
        @status = trace[2]
        @headers = trace[3]
        @hash = trace[4]
      end
    end
  end
end
