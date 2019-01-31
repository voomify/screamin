require 'sinatra/base'
require 'screamin/repository/policy'
require 'screamin/storage'

module Screamin
  module Routes
    class Policy < Sinatra::Base
      include Storage

      post '/screamin/add_path_strategy' do
        method = params['key'][0]
        path = params['key'][1]
        policy_ = if params['cache']
                    policy.add_path_strategy(method, path)
                  else
                    policy.remove_path_strategy(method, path)
                  end
        policy_repo.save!(policy_)
        content_type :json
        {messages: {snackbar: ["Strategy #{params['cache'] ? 'added to' : 'removed from'} policy"]}}.to_json
      end

      post '/screamin/toggle_policy' do
        policy.toggle_active
        policy_repo.save!(policy)
        content_type :json
        {messages: {snackbar: ["Policy caching #{params['toggle_policy_active'] ? 'activated' : 'deactivated'}"]}}.to_json
      end

      post '/screamin/toggle_policy_strategy' do
        strategy = policy.request_strategy(*params['key'])
        strategy.toggle_active
        policy_repo.save!(policy)
        content_type :json
        {messages: {snackbar: ["Strategy caching #{params['toggle_strategy_active'] ? 'activated' : 'deactivated'}"]}}.to_json
      end
      #
      # post '/screamin/collect_data' do
      #   new_state = repo.toggle_data_collection
      #   content_type :json
      #   {data_collection: new_state, messages: {snackbar: ["Data collection turned #{new_state ? 'on' : 'off'}"]}}.to_json
      # end
      #
      def policy_repo
        @repo ||= Repository::Policy.new(storage, params['app_name'], params['env_name'])
      end


      def policy
        @policy ||= policy_repo.policy
      end
    end
  end
end

