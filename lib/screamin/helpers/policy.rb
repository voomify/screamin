require_relative 'commands'
require 'screamin/helpers/app'
require 'screamin/entities/policy'
require 'screamin/repository/policy'
require 'screamin/storage'


module Screamin
  module Helpers
    module Policy
      include Helpers::Commands
      include Helpers::App
      include Storage


      def policy_repo
        @repo ||= Repository::Policy.new(storage, app_name, env_name)
      end


      def policy
        @policy ||= policy_repo.policy
      end
    end
  end
end
