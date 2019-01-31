#!/usr/bin/env ruby
# ENV['VOOM_ROOT'] = File.expand_path(__dir__)
# ENV['GOOGLE_API_KEY'] = 'AIzaSyDhSgj9XSBLY5E9Rx5pP2ILQ7IXnD4uX2Q'
# libdir = File.join(ENV['VOOM_ROOT'], 'lib')
# $:.unshift(libdir) unless $:.include?(libdir)
require 'screamin/web'
require 'redis'

run Screamin::Web


