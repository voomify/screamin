require_relative '../entities/app'
require_relative '../entities/analysis'
require_relative '../entities/trace'
require_relative '../storage'
require_relative '../debug'


module Screamin
  module Jobs
    class AnalyzeRequests
      include Debug
      include Storage

      def initialize(traces, app_name:, env_name:)
        @traces = traces
        @app_name = app_name
        @env_name = env_name

      end

      def process
        app_repo.save!(Screamin::App.new(@app_name).add_env(@env_name))
        debug @traces
        @traces.each do |trace_|
          trace = Trace.new(trace_)
          req_key = [trace.host, trace.request_method, trace.path]
          last_analysis = analysis_repo.request(req_key)
          new_analysis = Analysis.new(last_analysis, trace)
          debug "Storing request analysis: #{new_analysis.inspect}"
          analysis_repo.save_analysis(req_key, new_analysis)
        end
      end

      def analysis_repo(storage = self.storage)
        @analysis_repo ||= Repository::Analysis.new(storage, @app_name, @env_name)
      end


      def app_repo(storage = self.storage)
        @app_repo ||= Repository::App.new(storage)
      end
    end
  end
end
