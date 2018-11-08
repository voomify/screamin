require "screamin/version"
require "logger"
require 'json'
require 'digest'

module Screamin
  class Error < StandardError; end
  class Fast
    ALLOWED_VALUE_TYPES = [NilClass,TrueClass,FalseClass,String,Integer,Float,BigDecimal,Array,Hash]
    
    def initialize(rack_app, _key)
      @rack_app = rack_app
      @logger = Logger.new(File.new(File.join('log','screaming.log'), 'w'))
    end

    def call(env)
      trace = []
      trace << env.map{|k,v| [k,ALLOWED_VALUE_TYPES.include?(v.class) ? v : v.to_s]}.to_h
      result = @rack_app.call(env)
      trace << [result[0],result[1],Digest::MD5.hexdigest(result[2].to_s)]
      @logger.info(trace.to_json)
      result
    end

    def self.call(app, key)
      self.new(app, key)
    end
  end
end
