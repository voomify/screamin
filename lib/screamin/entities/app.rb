require 'rack/utils'
require 'forwardable'

module Screamin
  # Tracks all requests for analysis
  # From analysis a user can build a caching policy by turning on or off caching for given method:route:[]key:value,...]
  class App
    attr_reader :name, :environments

    def initialize(name)
      @name = name
      @environments = []
      self
    end

    # Idepmpotent
    def add_env(env)
      @environments << Environment.new(@name, env.to_s)
      @environments.uniq!
      self
    end

    class Environment
      attr_reader :app_name, :name

      def initialize(app_name, env_name)
        @app_name = app_name
        @name = env_name
      end

      def ==(other)
        self.app_name == other.app_name &&
        self.name == other.name
      end
    end
  end
end
