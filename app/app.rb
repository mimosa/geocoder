# -*- encoding: utf-8 -*-
require 'grape'
require 'config/database'
require 'lib/geocoder'
require 'lib/shortener'
require 'lib/smsbao'
require 'helpers/base_helpers'

class API < Grape::API
  format  :json

  helpers ::BaseHelpers

  before do
    header 'X-Robots-Tag', 'noindex'
    header 'Content-Type', 'application/json; charset=utf-8'
  end

  resource :geocoder do
    desc "IP地址。"
    get '/' do
      result   = {}
      location = remote_ip

      # IP
      unless location.nil?
        @geocoder = Geocoder.new
             geo  = @geocoder.get(location)

        result.merge!(geo) unless geo.nil?
      end

      # 结果
      result
    end

    desc "翻译地址。"
    params do
      requires :loc, type: String, desc: "地址或IP"
    end
    get ':loc', requirements: { loc: /(.*)/ } do
      result   = {}
      location = params[:loc].force_encoding('utf-8')

      # 手机号段
      mobile = location[0..6] 
      if (location.size == 11 && mobile.to_i > 1300000)
        geo = redis.hgetall(mobile)
        unless geo.empty?
          result[:provide] = geo['provide']
          result[:mobile]  = location
          location = geo['location']
        end
      end

      # 身份证号段
      idcard = location[0..5] 
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

  resource :shortener do
    desc "转短网址，状态。"
    get '/' do
      { status: 'ok' }
    end

    desc "转短网址。"
    params do
      requires :provider, type: String, desc: "提供商"
      requires :long_url, type: String, desc: "长网址"
    end
    get ':provider' do
      params[:provider] ||= 'sina'
      long_url = params[:long_url]
      @shortener = Shortener.new
      case params[:provider]
      when 'tencent'
        @shortener.tencent(long_url)
      else
        @shortener.sina(long_url)
      end
    end
  end

  resource :smssender do
    desc "查找余额。"
    get '/' do
      require_login!

      @smssender.balance
    end

    desc "生成钥匙。"
    params do
      requires :login,  type: String, desc: "用户名"
      requires :passwd, type: String, desc: "密码"
    end
    get '/token' do
      { 'X-Auth-Token' => Base64.strict_encode64("#{params[:login]}:#{params[:passwd]}") }
    end

    desc "发送短信。"
    params do
      requires :mobile,  type: String, desc: "手机号"
      requires :content, type: String, desc: "短信内容"
    end
    post '/' do
      require_login!

      mobile = if params[:mobile].size == 11
        params[:mobile].to_i
      else
        split_str( params[:mobile] )
      end

      @smssender.send(mobile, params[:content].force_encoding('utf-8'))
    end
  end

end