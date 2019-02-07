require 'sinatra/base'
require 'screamin/repository/policy'
require 'screamin/storage'

module Screamin
  module Routes
    class Policy < Sinatra::Base
      include Storage

      post '/screamin/toggle_strategy' do
        domain, method, path = params['key']
        if params['cache']
          s = policy.add_strategy(domain, method, path)
          if params['cache_keys']
            cache_keys = params['cache_keys'].map do |json|
              key, value = JSON.parse(json)
              [key.to_sym, value]
            end.to_h
            s.add_cache_key(cache_keys)
          end
        else
          policy.remove_strategy(domain, method, path)
        end
        policy_repo.save!(policy)
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

