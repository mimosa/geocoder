# -*- encoding: utf-8 -*-
require 'base64'
require 'nestful'
require 'multi_json'
require 'geocoder' # 地理位置

module BaseHelpers
  # 用户令牌
  def token_base64
    env['rack.session'][:token_base64] ||= headers['X-Auth-Token']
  end

  def geocoder(location)
    @geocoder ||= Geocoder.new
       result = @geocoder.get(location)
    return result unless result.nil?
    {}
  end

  def weather(code)
    request = Nestful.get("http://m.weather.com.cn/data/#{code}.html") rescue nil
    return MultiJson.load(request.body) unless request.nil?
    {}
  end

  # 帐号
  def smsbao_login
    return nil if token_base64.nil?
    return @smsbao_login if defined?(@smsbao_login)
    set_smsbao_user(token_base64, 'login')
  end

  # 密码
  def smsbao_passwd
    return nil if token_base64.nil?
    return @smsbao_passwd if defined?(@smsbao_passwd)
    set_smsbao_user(token_base64, 'passwd')
  end

  # 请求登录
  def require_login!
    error!('401 Unauthorized', 401) unless smsbao_login
    @smssender ||= Smsbao.new(smsbao_login, smsbao_passwd)
  end

  def set_smsbao_user(token_base64, type)
    return nil if token_base64.nil?

    login_arr = split_str( Base64.decode64(token_base64) )
    if login_arr.count == 2
      @smsbao_login  = login_arr[0]
      @smsbao_passwd = login_arr[1]
      env['rack.session'][:token_base64] = token_base64
      # 返回
      case type
      when 'login'
        @smsbao_login
      when 'passwd'
        @smsbao_passwd
      end
    end
  end

  def remote_ip
    @remote_ip ||= @env['HTTP_X_FORWARDED_FOR']
    @remote_ip ||= @env['HTTP_X_REAL_IP']
    @remote_ip ||= @env['HTTP_CLIENT_IP']
    @remote_ip ||= @env['REMOTE_ADDR']
  end

  def split_str(value)
    value.split(/,|，|\/|\||:/).collect { |node| node.strip }.uniq
  end

end
