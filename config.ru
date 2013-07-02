#!/usr/bin/env rackup
# encoding: utf-8
$LOAD_PATH << '.'
require 'rack'
require 'config/boot'
require 'app/app'

# 静态文件
use Rack::Static, urls: [ '/favicon.ico'], root: 'public'

# 运行 Grape
run Rack::Cascade.new([
  API
])