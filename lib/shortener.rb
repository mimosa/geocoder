# -*- encoding: utf-8 -*-
require 'nestful'
require 'multi_json'

class Shortener

  def initialize
    @protocol = 'http://'
  end

  def sina(str)
    json = sina_json(str)
    sina_parse(json) unless json.nil?
  end

  def tencent(str)
    json = tencent_json(str)
    tencent_parse(json) unless json.nil?
  end

  def client(url, params={})
    request = Nestful.get(url, params, {:format => :json}) rescue nil
    MultiJson.load(request.body) unless request.nil?
  end

  private

  def sina_json(str)
    client(sina_url, { url_long: str, source: 5786724301 })
  end

  def tencent_json(str)
    client(tencent_url, { 
            format: 'json', 
          long_url: str, 
      access_token: '625bcd4223e4ff9a32cbdf7e6a872c84', 
            appkey: 801058005,
oauth_consumer_key: 801058005,
             appid: 801058005,
         appsecret: '31cc09205420a004f3575467387145a7', 
            openid: 'EB965B8B5C5587CF8845393802893750', 
           openkey: '0F96FA09BB1F03BFE3C7F1E97680ADB8',
     oauth_version: '2.a',
             scope: 'all',
           appfrom: 'php-sdk2.0beta',
             seqid: 1373608137,
          clientip: '116.231.75.203',
          serverip: '183.60.10.172',
    })
  end

  def sina_parse(json)
    json = json['urls'][0]
    if json['result'] == true
      json['url_short']
    end
  end

  def tencent_parse(json)
    uri = @protocol + 'url.cn/'
    if json['errcode'] == 0
      uri + json['data']['short_url']
    end
  end

  def sina_url
    @protocol + 'api.weibo.com/2/short_url/shorten.json'
  end

  def tencent_url
    @protocol + 'open.t.qq.com/api/short_url/shorten'
  end

end