# -*- encoding: utf-8 -*-
require 'grape'
require 'config/database'
require 'lib/geocoder'

class API < Grape::API
  format  :json

  before do
    header 'X-Robots-Tag', 'noindex'
    header 'Content-Type', 'application/json; charset=utf-8'
  end

  desc "翻译地址。"
  params do
    requires :loc, type: String, desc: "地址或IP"
  end
  get '/' do
    result   = {}
    location = params[:loc].force_encoding('utf-8')
    
    mobile = location[0..6] # 手机号段
    if (location.size == 11 && mobile.to_i > 1300000)
      geo = redis.hgetall(mobile)
      unless geo.empty?
        result[:provide] = geo['provide']
        result[:mobile]  = location
        location = geo['location']
      end
    end
    
    idcard = location[0..5] # 身份证号段
    if (location.size == 18 && idcard.to_i > 110000)
      geo = redis.hgetall(idcard)
      unless geo.empty?
        result[:idcard]  = location
        location = geo['location']
      end
    end

    # IP 或 地址 查询
    unless location.nil?
      @geocoder = Geocoder.new
      geo  = @geocoder.get(location)
      result.merge!(geo) unless geo.nil?
    end
    # 结果
    result
  end
  
end