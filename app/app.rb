# -*- encoding: utf-8 -*-
require 'grape'
require 'config/database'
require 'lib/geocoder'

class API < Grape::API
  format  :json

  before do
    header 'X-Robots-Tag', 'noindex'
    header 'Content-Type', 'application/json'
  end

  desc "翻译地址。"
  params do
    requires :loc, type: String, desc: "地址或IP"
  end
  get '/' do
    location = params[:loc].force_encoding('utf-8')
    result   = {}
    # 手机归属地查询
    if (location.size == 11 && location.to_i > 13000000001)
      geo = redis.hgetall(location[0..6])
      unless geo.empty?
        result[:provide] = geo['provide']
        result[:mobile]  = location
        location = geo['location']
      end
    end
    # IP 或 地址 查询
    unless location.nil?
      @geocoder = Geocoder.new
      geo  = @geocoder.get(location)
      result.merge!(geo)
    end
    # 结果
    result
  end
  
end