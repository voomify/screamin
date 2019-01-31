require 'rack/utils'

module Screamin
  module Helpers
    module Commands
      def command_path(command, **params)
        "#{router.base_url}/screamin/#{command}?#{Rack::Utils.build_nested_query(params)}"
      end
    end
  end
end
