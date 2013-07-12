#!/usr/bin/env rackup
# encoding: utf-8
require 'rack'
require 'rack/session/redis'

$LOAD_PATH << '.'

require 'config/boot'
require 'app/app'

# 静态文件
use Rack::Static, urls: [ '/favicon.ico'], root: 'public'
use Rack::Session::Redis

# 运行 Grape
run Rack::Cascade.new([
  API
])