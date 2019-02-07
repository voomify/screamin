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
    def add_env(env_name)
      @environments << env_name
      @environments.uniq!
      self
    end
  end
end
