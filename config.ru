#!/usr/bin/env rackup
# encoding: utf-8
require 'lib/utils/file_set'

# auto load
FileSet.glob_require('config/{boot,database}.rb', __FILE__)
FileSet.glob_require('lib/*.rb', __FILE__)
FileSet.glob_require('lib/{helpers,utils}/*.rb', __FILE__)
FileSet.glob_require('app/*.rb', __FILE__)

##
# We need to apply Utils::Extensions
#
String.send(:include, Utils::Crypt)

# 静态文件
use Rack::Static, urls: [ '/favicon.ico', '/uploads' ], root: 'public'
use Rack::Session::Redis

# 运行 Grape
run Rack::Cascade.new([
  API
])