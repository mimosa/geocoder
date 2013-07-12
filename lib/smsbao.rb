# -*- encoding: utf-8 -*-
require 'digest/md5'
require 'nestful'

class Smsbao

  def initialize(login, passwd)
    @login  = login
    @passwd = Digest::MD5.hexdigest(passwd.to_s)
  end

  # 发送短信
  def send(mobile, content, force = false)
    payment    = price(content.size, default_limit[:content]) # 计费条数
    timesstamp = Time.now.strftime("%Y%m%d-%H%M")

    if mobile.is_a?(Array) # 群发
      
      # 中断发送，禁止批量发送长短信
      if payment > 1 
        message = "警告：此内容群发，预计产生 #{mobile.count*payment}条 费用！"
        unless force
          return { success: false, message: message } 
        end
      end
      # 粗略检测，手机号
      mobile = check_mobile(mobile)
      # 预计结果
      result = { pending: mobile[:approved], sent: [], fail: mobile[:rejected], fee: 0 }

      mobile = result[:pending]
      total  = mobile.count
      if total > 0
        mobile.each_slice( default_limit[:mobile] ).to_a.each do |batch| # 最大支持300为一组进行发送。
          response = client('send', { m: batch.join(','), c: content })
          stat = status(response)

          if stat[:success]
            # 状态转换
            result[:sent]    += batch
            result[:pending] -= batch
            # 计费
            result[:fee]     += (batch.count * payment)
          else
            return stat.merge(result) # 中断发送，返回错误
          end
        end

        return { success: true,  message: '短信队列成功。' }.merge(result) # 成功
      else
        return { success: false, message: '无效的手机号！' }.merge(result) # 验证错误
      end
    else # 单发
      mobile = mobile.to_s.strip.to_i
      
      if check?(mobile)
        response = client('send', { m: mobile, c: content.force_encoding('utf-8') })
        stat = status(response)

        return stat.merge({fee: payment}) # 返回发送状态
      else
        return { success: false, message: '无效的手机号！' } # 验证错误
      end
    end
  end

  # 查询余额
  def balance
    response = client('balance')
    return status(response)
  end

  private

  # 内容被拆分的条数
  def price(total, size)
    count = (total / size)
    count += 1 if (total % size) > 0
    return count
  end

  def check_mobile(mobile_arr)
    approved = []
    rejected = []

    mobile_arr.each do |mobile|
      mobile = mobile.to_s.strip.to_i
      if check?(mobile)
        approved << mobile
      else
        rejected << mobile
      end
    end
    return { approved: approved.uniq, rejected: rejected.uniq }
  end

  def check?(mobile)
    mobile = mobile.to_s
    return mobile.size == 11 && mobile[0] == '1'
  end

  def default_limit # 默认限制
    { content: 64, mobile: 300 }
  end

  def status(resp)
    arr = resp.split("\n")
    code = arr[0]
    message = case code
      when '0'
        if arr[1].nil?
          '短信发送成功'
        else
          vals = arr[1].split(",")
          {sent: vals[0].to_i, balance: vals[1].to_i}
        end
      when '30'
        '密码错误'
      when '40'
        '账号不存在'
      when '41'
        '余额不足'
      when '42'
        '帐号过期'
      when '43'
        'IP地址限制'
      when '50'
        '内容含有敏感词'
      when '51'
        '手机号码不正确'
      when '-1'
        '缺少参数'
    end
    { success: (code == '0'), message: message }
  end

  def gw_url(method)
    'http://www.smsbao.com' + method_path[method.to_sym]
  end

  def method_path
    { send: '/sms', balance: '/query' }
  end

  def client(method, params={})
    Nestful.get gw_url(method), { u: @login, p: @passwd }.merge(params)
  end
end