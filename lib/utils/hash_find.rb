# -*- encoding: utf-8 -*-

module Utils
  module HashFind
    
    def find_by_subkey(q, field)
      select { |key, value| value[field].match(/^#{q}\S+/) }
    end

    def find_by_key(q)
      select { |key| key.match(/^#{q}\S+/) }
    end

    def find_keys(path)
      path.split(".").inject(self) { |hash, key| hash[key] }
    end

  end # HashFind
end # Utils

Hash.send(:include, Utils::HashFind)