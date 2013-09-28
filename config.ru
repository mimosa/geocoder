#!/usr/bin/env rackup
# encoding: utf-8
# $LOAD_PATH.unshift File.expand_path('lib', File.dirname(__FILE__))
$: << './lib'

require 'utils/file_set'
require 'utils/crypt'
require 'utils/hash_find'
require 'utils/array_find'

# auto load
FileSet.glob_require('config/{boot,database}.rb', __FILE__)
FileSet.glob_require('app/*.rb', __FILE__)

# 静态文件
use Rack::Static, urls: [ '/favicon.ico', '/uploads' ], root: 'public'
use Rack::Session::Redis
require 'rack/cors'
# 
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, :methods => :get
  end
end
# 运行 Grape
run Rack::Cascade.new([
  API
])