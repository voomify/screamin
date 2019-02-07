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

      post '/screamin/add_cache_key' do
        set_cache_key(true)
        content_type :json
        {}.to_json
      end

      post '/screamin/remove_cache_key' do
        set_cache_key(false)
        content_type :json
        {}.to_json
      end

      def analysis_repo
        @analysis_repo ||= Repository::Analysis.new(storage, params['app_name'], params['env_name'])
      end

      def set_cache_key(state)
        analysis = analysis_repo.request(params['key'])
        cacheable_request = analysis.status.dig(Integer(params['status_code']), params['hash'])
        request_param = cacheable_request.send(params['collection'].to_sym).fetch(params['param_key'])
        request_param.cache_key = state
        analysis_repo.save_analysis(params['key'], analysis)

      end

    end
  end
end

