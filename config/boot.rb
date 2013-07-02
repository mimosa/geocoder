# -*- encoding: utf-8 -*-

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'

unless RUBY_VERSION < '1.9'
  Encoding.default_internal = nil
end