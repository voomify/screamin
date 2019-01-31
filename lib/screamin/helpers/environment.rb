require 'screamin/config'

module Screamin
  module Helpers
    module Environment
      def collect_for_current_env?
        Screamin.config.analysis.environments
            .include?(ENV['RAILS_ENV'] || ENV['RACK_ENV'])
      end
    end
  end
end
