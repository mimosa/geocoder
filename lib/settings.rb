# -*- encoding: utf-8 -*-
require 'securerandom'
require 'multi_json'
require 'multi_xml'
require 'psych'

class Settings

  def initialize(token)
    @token = token.to_s
    
    # 新文件
    unless file?
      @token = token.to_s.encrypt(secure_token)
    end
  end

  def file?
    @has_file ||= File.exist?(file_name)
  end

  # 查找
  def find(q)
    case
    when decode.is_a?(Array)
      decode.find_by(q)
    when decode.is_a?(Hash)
      decode.find_by_key(q, field)
    end
  end
  
  # 查找
  def find_by(q, field)
    case
    when decode.is_a?(Array)
      decode.find_by_hash(q, field)
    when decode.is_a?(Hash)
      decode.find_by_subkey(q, field)
    end 
  end

  def decode
    @decoded ||= Psych.load_file(file_name)
  end

  def to_json
    @json ||= MultiJson.dump(decode)
  end

  def by_xml(str)
    hash = MultiXml.parse(str) rescue nil
    encode(hash)
  end

  def by_json(str)
    hash = MultiJson.load(str) rescue nil
    encode(hash)
  end

  def encode(hash)
    # 打开
    file = File.open(file_name, "wb:UTF-8")
    # 写内容
      Psych.dump(hash, file) unless hash.nil?
    reload # 自动重载
    # 关闭
    file.close
  end

  def to_s
    @token
  end

  def delete
    File.delete(file_name)
  end

  private

  def reload
    @has_file = true
    @decoded  = @json = nil
  end

  def file_name
    "public/uploads/#{@token}.yml"
  end

  def secure_token(length = 16)
    SecureRandom.hex(length / 2)
  end
end