# -*- encoding: utf-8 -*-
require 'redis'
require 'psych'

def redis_conf
  @_conf ||= Psych.load_file('config/redis.yml')[ENV['RACK_ENV'] || 'development']
end

def redis
  @_redis ||= Redis.new(
    host: redis_conf[:host], 
    port: redis_conf[:port], 
    password: redis_conf[:password],
    db: redis_conf[:database]
  )
end

def redis
  @_redis ||= Redis.new(
    host: redis_conf[:host], 
    port: redis_conf[:port], 
    password: redis_conf[:password],
    db: redis_conf[:database]
  )
end