# -*- encoding: utf-8 -*-

module Utils
  module ArrayFind
    
    def find_by(q)
      self.find_all {|x| x =~ /^#{q}\S+/ }
    end

    def find_by_hash(q, field)
      self.find_all {|x| x[field] =~ /^#{q}\S+/ }
    end

  end # ArrayFind
end # Utils

Array.send(:include, Utils::ArrayFind)