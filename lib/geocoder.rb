# -*- encoding: utf-8 -*-
require 'nestful'
require 'multi_json'

class Geocoder

  def initialize(language='zh_CN')
    @language   = language
  end

  def get(str)
    if check_ip(str)
      json = ip_json(str)
      ip_parse(json) unless json.nil?
    else
      json = address_json(str)
      address_parse(json) unless json.nil?
    end
  end

  def client(url, params={})
    request = Nestful.get(url, params, {:format => :json}) rescue nil
    MultiJson.load(request.body) unless request.nil?
  end

  def translate(str)
    json = translate_json(str)
    translate_parse(json) unless json.nil?
  end

  private
  
  # IP
  def ip_url
    'http://www.geoplugin.net/json.gp'
  end

  def ip_json(str)
    client(ip_url, { ip: str })
  end

  def ip_parse(json)
    engs = [json['geoplugin_city'], json['geoplugin_regionName'], json['geoplugin_countryName']].join('|')
    chs  = if @language == 'en'
      engs.split('|')
    else
      translate(engs).split('|')
    end
    # 谷歌翻译会合并相同单词
    if chs[0].empty?
      chs[0] = chs[1]
    end
    {
      city: chs[0],
      region: chs[1],
      country: chs[2],
      latitude: json['geoplugin_latitude'].to_f,
      longitude: json['geoplugin_longitude'].to_f
    }
  end

  # 地址
  def address_url
    'http://maps.googleapis.com/maps/api/geocode/json'
  end

  def address_json(str)
    client(address_url, { address: str, sensor: false, language: @language})
  end

  def address_parse(json)
    result = {}
    if json['status'] == 'OK'
      json = json['results'][0]
      # 地址
      result[:location] = json['formatted_address']
      # 行政区域解析
      addresses = json['address_components']
      addresses.each do |address|
        type = address['types'][0]
        case type
        when 'sublocality'
          result[:district] = address['long_name']
        when 'locality'
          result[:city] = address['long_name']
        when 'administrative_area_level_1'
          result[:region] = address['long_name']
        when 'country'
          result[:country] = address['long_name']
        end 
        if ['route', 'neighborhood'].include?(type)
          result[:street] = address['long_name']
        end
        if ['street_number', 'establishment'].include?(type)
          result[:street_number] = address['long_name']
        end
      end
      # 坐标
      geometry = json['geometry']
      # 经纬
      if geometry.has_key?('location')
         result[:latitude] = geometry['location']['lat']
        result[:longitude] = geometry['location']['lng']
      end
      # 边界
      if geometry.has_key?('bounds')
        result[:bounds] = {}
        result[:bounds][:north] = geometry['bounds']['northeast']['lat']
        result[:bounds][:south] = geometry['bounds']['southwest']['lat']
        result[:bounds][:east] = geometry['bounds']['northeast']['lng']
        result[:bounds][:west] = geometry['bounds']['southwest']['lng']
      end
    end
    return result
  end

  # 翻译
  def translate_url
    'http://translate.google.com/translate_a/t'
  end

  def translate_json(str)
    client(translate_url, { client: 'p', langpair: 'en|zh-CN', text: str, ie: 'UTF-8', oe: 'UTF-8'})
  end

  def translate_parse(json)
    json['sentences'][0]['trans']
  end

  # 检查IP
  def check_ip(str)
    return false if str.blank?
    ip = str.split('.')
    if ip.count == 4
      ip = ip.join.to_i
      return ip > 1000 && ip < 255255255255
    end
    return false
  end
end
