require 'sinatra/base'
require 'screamin/repository/analysis'
require 'screamin/storage'
module Screamin
  module Routes
    class Analysis < Sinatra::Base
      include Storage

      post '/screamin/reset_analysis_data' do
        analysis_repo.reset_data!
        content_type :json
        {messages: {snackbar: ['Data collection reset!']}}.to_json
      end

      post '/screamin/collect_data' do
        new_state = analysis_repo.toggle_data_collection
        content_type :json
        {data_collection: new_state, messages: {snackbar: ["Data collection turned #{new_state ? 'on' : 'off'}"]}}.to_json
      end

      def analysis_repo
        @analysis_repo ||= Repository::Analysis.new(storage, params['app_name'], params['env_name'])
      end

    end
  end
end

