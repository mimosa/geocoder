# -*- encoding: utf-8 -*-
require 'date'
require 'nestful'
require 'multi_json'

class Weather

  def get(code)
    request = Nestful.get("http://m.weather.com.cn/data/#{code}.html") rescue nil
    unless request.nil?
      result = MultiJson.load(request.body)
      if result.has_key?('weatherinfo')
        return weather_parse(result['weatherinfo'])
      end
    end
    {}
  end

  def temp_parse(str, unit)
    result = str.match(/(.*)#{unit}~(.*)#{unit}/)
    unless result.nil?
      return {
        min: result[2].to_f,
        max: result[1].to_f,
        title: "#{result[2]}℃~#{result[1]}℃"
      }
    end
    {}
  end

  def get_weather(json, num)
    { 
      weather: json["weather#{num}"],
      temp: {
           celsius: temp_parse(json["temp#{num}"], '℃'),
        fahrenheit: temp_parse(json["tempF#{num}"],'℉')
      },
      wind: json["wind#{num}"],
    }
  end

  def weather_parse(json)
    week_labels = ['星期日', '星期日', '星期一', '星期二', '星期三', '星期四', '星期五']
       start_at = Date.today
         result = { city: json['city'], date: start_at.to_s, week: week_labels[start_at.wday] }
    # 今日天气    
    result.merge!( get_weather(json, 1) ) 
    # 后续5天，天气
    days = []
    (2..6).each do |i|
      day = (start_at + i)
      days << { date: day.to_s, week: week_labels[day.wday] }.merge(get_weather(json, i))
    end

    result[:next_days] = days
    # 今日指数
    result[:tips] = {
      clad: json['index_d'],
      uv: json['index_uv'],
      cleanning: json['index_xc'],
      travel: json['index_tr'],
      allergy:  json['index_ag'],
      drying: json['index_ls'],
      morning: json['index_cl'],
    }

    return result
  end
end
