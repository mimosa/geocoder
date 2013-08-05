# -*- encoding: utf-8 -*-
require 'grape'
# 
require 'shortener' # 短网址
require 'smsbao'   # 短信
require 'settings' # YAML配置文件
# Helpers
require 'helpers/base_helpers'

class API < Grape::API
  format  :json
  content_type :xml, 'text/xml'

  helpers ::BaseHelpers

  before do
    header 'X-Robots-Tag', 'noindex'
    header 'Content-Type', 'application/json; charset=utf-8'
  end

  desc "首页。"
  get '/' do
    { 
      geocoder: {},
      shortener: {},
      smssender: {},
      settings: {},
      weather: {}
    }
  end

  resource :geocoder do
    desc "IP地址。"
    get '/' do
      result   = {}
      location = remote_ip

      # IP
      result.merge!( geocoder(location) ) unless location.nil?

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
      result.merge!( geocoder(location) ) unless location.nil?

      # 结果
      result
    end
  end

  resource :weather do
    desc "当前城市，天气预报。"
    get '/' do
      result   = {}
      location = remote_ip

      # IP
      result.merge!( geocoder(location) ) unless location.nil?

      # 结果
      if result.has_key?('city')
        city_name = result['city']
             city = redis.hgetall(city_name)
      result.merge!( weather(city['code']) ) unless city.nil?
      end

      result
    end

    desc "天气预报。"
    params do
      requires :city, type: String, desc: "城市"
    end
    get ':city' do
      city = redis.hgetall( params[:city].force_encoding('utf-8') )
      return weather(city['code']) unless city.empty?
      {}
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

  resource :settings do
    desc "状态。"
    get '/' do
      { status: 'ok' }
    end

    desc "提取配置。"
    params do
      requires :token, type: String, desc: "提取码"
    end
    get ':token' do
      @props = Settings.new(params[:token])
      if @props.file?
        @props.decode 
      else
        error!('404 Not Found', 404)
      end
    end

    desc "查询。"
    params do
      requires :token, type: String, desc: "提取码"
      requires :q, type: String, desc: "查询"
    end
    get ':token/search' do
      @props = Settings.new(params[:token])
      @props.find(params[:q].force_encoding('utf-8')) if @props.file?
    end

    desc "查询字段。"
    params do
      requires :token, type: String, desc: "提取码"
      requires :field, type: String, desc: "字段"
      requires :q, type: String, desc: "查询"
    end
    get ':token/search/:field' do
      @props = Settings.new(params[:token])
      @props.find_by(params[:q].force_encoding('utf-8'), params[:field]) if @props.file?
    end

    desc "更新配置。"
    params do
      requires :token, type: String, desc: "提取码"
    end
    post ':token' do
      @props = Settings.new(params[:token])
      # 踢出
      # params.reject! {|k, v| %w"route_info token".include? k }
      body = env['api.request.input']
      case env['CONTENT_TYPE']
      when 'text/xml'
        @props.by_xml(body)
      when 'application/json'
        @props.by_json(body)
      end
      
      redirect "/settings/#{@props.to_s}"
    end

    desc "删除配置。"
    params do
      requires :token, type: String, desc: "提取码"
    end
    delete ':token' do
      @props = Settings.new(params[:token])
      @props.delete if @props.file?

      redirect "/settings"
    end
  end

end